
## INPUTS

# Who made it to playoffs?
AFC = [
    "KC"    1711    39.04886980885212   -94.48402061049137
    "BUF"   1682    42.77368370047009   -78.78699375843608
    "PIT"   1578    40.44667300240402   -80.01575060079283
    "TEN"   1572    36.166478980084065  -86.77126834317069
    "BAL"   1651    39.27799588452784   -76.62274731615189
    "CLE"   1578    41.50605347925382   -81.6995481007797
    "IND"   1594    39.76007593673786   -86.16388770080121
]

NFC = [
    "GB"    1675    44.50133292692987   -88.06224048724964
    "NO"    1731    29.951033093843595  -90.08124420090734
    "SEA"   1620    47.59518071977613   -122.33161794302632
    "WSH"   1453    38.90760165130806   -76.8646034796092
    "TB"    1618    27.975878557801302  -82.50333440092545
    "LAR"   1591    33.95336110126225   -118.33880341933201
    "CHI"   1497    41.862329159836804  -87.61668840077519
]

# Where is superbowl played?
SUPERBOWL_LOC = [27.975858977287004, -82.50333903413046]

# What were the picks people made?
PICKS = [
    "Akhil" => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "GB", "BUF", "BUF"],
    "Steve" => [ "TB", "SEA",  "NO", "TEN", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "GB", "BUF", "BUF"],
    "Dustin"=> [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "NO",  "KC",  "KC"],
    "Jacob" => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "NO",  "KC",  "KC"],
    "David" => [ "TB", "LAR",  "NO", "TEN", "PIT", "BUF",  "GB",  "TB",  "KC", "BUF",  "GB", "BUF", "BUF"],
    "Eric"  => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "TB",  "NO",  "KC", "BUF",  "NO",  "KC",  "KC"],
    "Mo"    => [ "TB", "LAR",  "NO", "BAL", "CLE", "BUF",  "GB",  "TB",  "KC", "BUF",  "GB",  "KC",  "KC"],
    "Ben"   => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "TB",  "NO", "BAL", "BUF",  "NO", "BUF", "BUF"]
]

# Who has played and won their games already?
WINS = ["BUF", "LAR", "TB", "BAL", "NO", "CLE", "GB", "BUF", "KC", "TB"]









struct Location
    lat::Float64
    lon::Float64
end
lat(l::Location) = l.lat
lon(l::Location) = l.lon
hav(θ) = (1.0-cos(θ))/2.0
function dist(l1::Location, l2::Location; r=3960.0)
    ϕ1 = deg2rad(lat(l1))
    ϕ2 = deg2rad(lat(l2))
    λ1 = deg2rad(lon(l1))
    λ2 = deg2rad(lon(l2))

    2r * asin(sqrt(hav(ϕ2-ϕ1) + cos(ϕ1)*cos(ϕ2)*hav(λ2-λ1)))
end


struct Team
    name::String
    seed::Int8
    elo::Float64
    home_loc::Location
end
home_loc(t::Team) = t.home_loc
elo(t::Team) = t.elo
seed(t::Team) = t.seed
highest_seed(T::Array{Team,1}) = T[argmax(seed.(T))]
lowest_2seed(T::Array{Team,1}) = T[sortperm(seed.(T))[end-1:end]]

# struct Game
#     team1::Team
#     team2::Team
#     loc::Location
#     hf_elo::Float64
#     rest_elo::Float64
#     playoff_mult_elo::Float64
# end
# team1(g::Game) = g.team1
# team2(g::Game) = g.team2
# PlayoffGame(t1::Team, t2::Team; rest_elo=0.0) = Game(t1, t2, home_loc(t1), 33.0, rest_elo, 1.2)
# SuperBowl(t1::Team, t2::Team, sb_loc::Location) = Game(t1, t2, sb_loc, 0.0, 0.0, 1.2)

function get_prob(g::Game)
    A_elo_base = elo(team1(g))
    B_elo_base = elo(team2(g))

    Δelo_home = g.hf_elo
    Δelo_travel = 4/1000 * (dist(g.loc, home_loc(team2(g))) - dist(g.loc, home_loc(team1(g))))
    Δelo_rest = g.rest_elo
    Δelo_mult = g.playoff_mult_elo

    elo_diff = Δelo_mult * (A_elo_base - B_elo_base + Δelo_home + Δelo_travel + Δelo_rest)

    1.0 / (1 + 10^(-elo_diff/400))
end



struct GameTree
    games::Array{Game,1} #all the games in the whole tree
    probs::Array{Float64,1}
end
function parent_is(i)
    is = [i]
    while i>1
        i = i ÷ 2
        push!(is, i)
    end
    reverse(is)
end
function winners(i, gt::Array{Game,1})
    p_is = parent_is(i)
    [iseven(i_n) ? gt[i].team1 : gt[i].team2 for (i,i_n) in zip(p_is[1:end-1], p_is[2:end])]
end
winners(i,gt::GameTree) = winners(i,gt.games)
row_is(row_num) = 2^(row_num-1):2^row_num-1

function get_prob(i_end, i_start, gt::GameTree)
    ps = zeros(length(i_end))
    for (j,ie) in enumerate(i_end)

        p_is = filter!(x-> x>=i_start, parent_is(ie))
        
        if !(i_start ∈ p_is)
            ps[j] = 0.0
            continue
        end

        ps[j] = prod([iseven(i_n) ? gt.probs[i] : (1.0-gt.probs[i]) for (i,i_n) in zip(p_is[1:end-1], p_is[2:end])])

    end

    ps
end

function get_score(pick,real)
    score = 1 * count(findall(in(real[1:6]),pick[1:6]))
    score += 2 * count(findall(in(real[7:10]),pick[7:10]))
    score += 4 * count(findall(in(real[11:12]),pick[11:12]))
    score += 8 * count(findall(in(real[13:13]),pick[13:13]))
end

function get_score_matrix(gt::GameTree)
    scores = zeros(Int8, 2^13, 2^13)
    for i in row_is(14)
        picks = winners(i, gt)
        for j in row_is(14)
            reals = winners(j, gt)
            scores[i,j] = get_score(picks, reals)
        end
    end
end


function prob(team1::Team, team2::Team; loc=nothing, rest=false, hf_adv=true, playoff=true)
    if isnothing(loc)
        loc = home_loc(team1)
    end
    rest ? Δelo_rest = 25 : Δelo_rest = 0
    hf_adv ? Δelo_home = 33 : Δelo_home = 0
    playoff ? elo_mult = 1.2 : elo_mult = 1.0

    Δelo_travel = 4/1000 * (dist(loc, home_loc(team2)) - dist(loc, home_loc(team1)))

    elo_diff = elo_mult * (elo(team1) - elo(team2) + Δelo_rest + Δelo_home + Δelo_travel)

    1.0 / (1 + 10^(-elo_diff/400))

end

function winners(i, gt::Array{Int8,2})
    p_is = parent_is(i)
    [iseven(i_n) ? gt[i,1] : gt[i,2] for (i,i_n) in zip(p_is[1:end-1], p_is[2:end])]
end







hav(θ) = (1.0-cos(θ))/2.0
function dist(l1, l2; r=3960.0)
    ϕ1, λ1 = deg2rad.(l1)
    ϕ2, λ2 = deg2rad.(l2)

    2r * asin(sqrt(hav(ϕ2-ϕ1) + cos(ϕ1)*cos(ϕ2)*hav(λ2-λ1)))
end




struct Game
    t1::Int8
    t2::Int8
    prob_t1::Float64
end

struct GameTree
    games::
    
end

function GameTree(afc_m, nfc_m, sb_loc)

    # We'll track the teams by an ID number, with AFC going from 1->7 and NFC from 11->17. It'll help with sorting and comparing
    teams = merge(
        Dict( 0+i => Team(row[1], i, row[2], Location(row[3],row[4])) for (i,row) in enumerate(eachrow(afc_m))),
        Dict(10+i => Team(row[1], i, row[2], Location(row[3],row[4])) for (i,row) in enumerate(eachrow(nfc_m)))
    )
    #And we'll keep a decoder ring
    teams_decoder = merge(
        Dict( row[1] =>  0+i for (i,row) in enumerate(eachrow(afc_m))),
        Dict( row[1] => 10+i for (i,row) in enumerate(eachrow(nfc_m)))
    )

    # All the 2^13-1 possible games will be identified in two column vector
    G = zeros(Int8, 2^13-1, 2)
    # And all the probabilities in another vector of the same size
    P = zeros(Float64, 2^13-1)

    # Wildcards
    #Game 1 - AFC 2 vs AFC 7 - i = 1:1
    G[row_is(1),:] .= [2 7]
    P[row_is(1)] .= prob(teams[2], teams[7])

    #Game 2 - NFC 3 vs NFC 6 - i = 2:3
    G[row_is(2),:] .= [13 16]
    P[row_is(2)] .= prob(teams[13], teams[16])

    #Game 3 - NFC 4 vs NFC 5 - i = 4:7
    G[row_is(3),:] .= [14 15]
    P[row_is(3)] .= prob(teams[14], teams[15])

    #Game 4 - AFC 4 vs AFC 5 - i = 8:15
    G[row_is(4),:] .= [4 5]
    P[row_is(4)] .= prob(teams[4], teams[5])

    #Game 5 - NFC 2 vs NFC 7 - i = 16:31
    G[row_is(5),:] .= [12 17]
    P[row_is(5)] .= prob(teams[12], teams[17])

    #Game 6 - AFC 3 vs AFC 6 - i = 32:63
    G[row_is(6),:] .= [3 6]
    P[row_is(6)] .= prob(teams[3], teams[6])


    #2nd round
    # Game 7 - NFC 1 vs weakest from winners of games 2,3,5 - nfc 1 gets 25 rest elo points
    G[row_is(7),:] = vcat([[11 maximum(winners(i,G)[[2,3,5]])] for i in row_is(7)]...)
    P[row_is(7)] = [prob(teams[G[i,1]], teams[G[i,2]], rest=true) for i in row_is(7)]

    append!(G, [PlayoffGame(nfc[1], highest_seed(winners(i,G)[[2,3,5]]), rest_elo=25) for i in row_is(7)])

    # Game 8 - Top winning AFC wildcard teams, so lowest seed winners from games 1,4,6
    append!(G, [PlayoffGame(lowest_2seed(winners(i,G)[[1,4,6]])...) for i in row_is(8)])

    # Game 9 - AFC 1 vs weakest from winners of games 1,4,6 - afc 1 gets 25 rest elo points
    append!(G, [PlayoffGame(afc[1], highest_seed(winners(i,G)[[1,4,6]]), rest_elo=25) for i in row_is(9)])

    # Game 10 - Top winning NFC wildcard teams, so lowest seed winners from games 1,4,6
    append!(G, [PlayoffGame(lowest_2seed(winners(i,G)[[2,3,5]])...) for i in row_is(10)])


    #3rd round
    # Game 11 - AFC Championship game - this will be winners of games 8 and 9
    append!(G, [PlayoffGame(winners(i,G)[[8,9]]...) for i in row_is(11)])

    # Game 12 - NFC Championship game - this will be winners of games 7 and 10
    append!(G, [PlayoffGame(winners(i,G)[[7,10]]...) for i in row_is(12)])


    #4th round
    # Game 13 - Superbowl - this will be winners of games 11 and 12
    append!(G, [SuperBowl(winners(i,G)[[11,12]]..., Location(sb_loc...)) for i in row_is(13)])

    probs = get_prob.(G)
    return GameTree(G, probs)
end




## Make Stuff
gtree = GameTree(AFC, NFC, SUPERBOWL_LOC)
outcome_probs = get_prob(row_is(14), 1, gtree)
score_matrix = get_score_matrix(gtree)

