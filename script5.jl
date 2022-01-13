#2021
# Who made it to playoffs, and how good are they?
TEAMS = Dict(
    1  => (" KC", 1711, (39.048914, -94.484039)),
    2  => ("BUF", 1682, (42.773739, -78.786978)),
    3  => ("PIT", 1578, (40.446786, -80.015761)),
    4  => ("TEN", 1572, (36.166461, -86.771289)),
    5  => ("BAL", 1651, (39.277969, -76.622767)),
    6  => ("CLE", 1578, (41.506022, -81.699564)),
    7  => ("IND", 1594, (39.760056, -86.163806)),
    
    11 => (" GB", 1675, (44.501306, -88.062167)),
    12 => (" NO", 1731, (29.950931, -90.081364)),
    13 => ("SEA", 1620, (47.595153, -122.33162)),
    14 => ("WSH", 1453, (38.907697, -76.864517)),
    15 => (" TB", 1618, (27.975967, -82.503350)),
    16 => ("LAR", 1591, (38.632975, -90.188547)),
    17 => ("CHI", 1497, (41.862306, -87.616672)),
)

# Where is superbowl played?
SUPERBOWL_LOC = (27.975967, -82.50335)

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






#2022
# Who made it to playoffs, and how good are they?
TEAMS = Dict(
    1  => ("TEN", 1590, (36.166461, -86.771289)),
    2  => (" KC", 1689, (39.048914, -94.484039)),
    3  => ("BUF", 1637, (42.773739, -78.786978)),
    4  => ("CIN", 1570, (39.095442, -84.516039)),
    5  => (" LV", 1480, (37.751411,-122.200889)),
    6  => (" NE", 1571, (42.090925, -71.264350)),
    7  => ("PIT", 1486, (40.446786, -80.015761)),

    11 => (" GB", 1680, (44.501306, -88.062167)),
    12 => (" TB", 1654, (27.975967, -82.503350)),
    13 => ("DAL", 1636, (32.747778, -97.092778)),
    14 => ("LAR", 1591, (38.632975, -90.188547)),
    15 => ("ARI", 1523, (33.527700,-112.262608)),
    16 => (" SF", 1580, (37.713486,-122.386256)),
    17 => ("PHI", 1508, (39.900775, -75.167453)),
)

# Where is superbowl played?
SUPERBOWL_LOC = (38.632975, -90.188547)

# What were the picks people made?
# PICKS = [
#     "Akhil" => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "GB", "BUF", "BUF"],
#     "Steve" => [ "TB", "SEA",  "NO", "TEN", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "GB", "BUF", "BUF"],
#     "Dustin"=> [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "NO",  "KC",  "KC"],
#     "Jacob" => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "GB",  "NO",  "KC", "BUF",  "NO",  "KC",  "KC"],
#     "David" => [ "TB", "LAR",  "NO", "TEN", "PIT", "BUF",  "GB",  "TB",  "KC", "BUF",  "GB", "BUF", "BUF"],
#     "Eric"  => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "TB",  "NO",  "KC", "BUF",  "NO",  "KC",  "KC"],
#     "Mo"    => [ "TB", "LAR",  "NO", "BAL", "CLE", "BUF",  "GB",  "TB",  "KC", "BUF",  "GB",  "KC",  "KC"],
#     "Ben"   => [ "TB", "SEA",  "NO", "BAL", "PIT", "BUF",  "TB",  "NO", "BAL", "BUF",  "NO", "BUF", "BUF"]
# ]

# Who has played and won their games already?
WINS = []


#### END INPUT ####
using StatsBase
using DelimitedFiles
using Distributions

function winner(game_i, round, T)
    while true
        n_i = game_i ÷ 2
        if n_i < 2^round
            if iseven(game_i)
                return(T[n_i][1])
            else
                return(T[n_i][2])
            end
        end
        game_i = n_i
    end
end

function get_teams(game_i, T)
    if     game_i < 2^1
        return (2,7)

    elseif game_i < 2^2
        return (13,16)

    elseif game_i < 2^3
        return (14,15)

    elseif game_i < 2^4
        return (4,5)

    elseif game_i < 2^5
        return (12,17)

    elseif game_i < 2^6
        return (3,6)

    elseif game_i < 2^7
        opp = maximum([winner(game_i,rnd,T) for rnd in [2,3,5]])
        return (11,opp)

    elseif game_i < 2^8
        tms = sort([winner(game_i,rnd,T) for rnd in [1,4,6]])
        return (tms[1],tms[2])
    
    elseif game_i < 2^9
        opp = maximum([winner(game_i,rnd,T) for rnd in [1,4,6]])
        return (1,opp)
    
    elseif game_i < 2^10
        tms = sort([winner(game_i,rnd,T) for rnd in [2,3,5]])
        return (tms[1],tms[2])

    elseif game_i < 2^11
        tms = sort([winner(game_i,rnd,T) for rnd in [8,9]])
        return (tms[1],tms[2])

    elseif game_i < 2^12
        tms = sort([winner(game_i,rnd,T) for rnd in [7,10]])
        return (tms[1],tms[2])

    elseif game_i < 2^13
        return (winner(game_i,11,T), winner(game_i,12,T))

    end
end

function get_playoff_structure()
    teams = Tuple{Int,Int}[]
    teams = [get_teams(i, teams) for i in 2^0:2^6-1]           #wc
    append!(teams, [get_teams(i, teams) for i in 2^6:2^10-1])  #conf
    append!(teams, [get_teams(i, teams) for i in 2^10:2^12-1]) #div
    append!(teams, [get_teams(i, teams) for i in 2^12:2^13-1]) #sb

    teams
end
PLAYOFFS = get_playoff_structure()


function get_lr(idx)
    n = idx + 8191
    c = falses(13)
    i = 13
    while n > 1
        if iseven(n)
            c[i] = true
            n = n/2
        else
            n = (n-1)/2
        end
        i-=1
    end
    c
end

hav(θ) = (1.0-cos(θ))/2.0
function dist(l1, l2; r=3960.0)
    ϕ1 = deg2rad(l1[1])
    ϕ2 = deg2rad(l2[1])
    λ1 = deg2rad(l1[2])
    λ2 = deg2rad(l2[2])

    2r * asin(sqrt(hav(ϕ2-ϕ1) + cos(ϕ1)*cos(ϕ2)*hav(λ2-λ1)))
end
# dist((32.322, -116.973), (44.869, -68.369)) #should be ~2719

```
Get winner predicted by difference in ELO according to https://fivethirtyeight.com/methodology/how-our-nfl-predictions-work/
```
function get_game_prob(t1, t2, wk)
    HOME_ADV = 55
    REST_ADV = 25
    PLAYOFF_MULT = 1.2

    t1_elo, t1_loc = TEAMS[t1][2:3]
    t2_elo, t2_loc = TEAMS[t2][2:3]

    if wk < 4
        l = t1_loc
    else
        l = SUPERBOWL_LOC
    end

    Δelo_travel = 4/1000 * (dist(l, t2_loc) - dist(l, t1_loc))

    if (wk==1) || (wk==2 && t1≠1 && t2≠11) || (wk==3) #Regular playoff games
        Δelo_home = HOME_ADV
        Δelo_mult = PLAYOFF_MULT
        Δelo_rest = 0
    elseif wk == 2 #Rest games for 1 seeds
        Δelo_home = HOME_ADV
        Δelo_mult = PLAYOFF_MULT
        Δelo_rest = REST_ADV
    elseif wk == 4 #Superbowl
        Δelo_mult = PLAYOFF_MULT
        Δelo_home = 0
        Δelo_rest = 0
    end

    elo_diff = Δelo_mult * (t1_elo - t2_elo + Δelo_home + Δelo_travel + Δelo_rest)

    pw_t1 = 1.0 / (1 + 10^(-elo_diff/400))

    pw_t1

end
# get_game_prob(1, 2, 4)

function get_week(i)
    if     i < 2^6
        wk = 1
    elseif i < 2^10
        wk = 2
    elseif i < 2^12
        wk = 3
    elseif i < 2^13
        wk = 4
    end
    wk
end

function get_prob(t1t2, i)
    get_game_prob(t1t2[1], t1t2[2], get_week(i))
end

GAME_PROBS = get_prob.(PLAYOFFS, 1:8191)

function get_branch(lr)
    b = zeros(Int,13)
    i = 1
    n = 1
    while i <= 13
        b[i] = n
        if lr[i]
            n = n*2
        else
            n = n*2+1
        end
        i += 1
    end
    b
end

function get_branch_num(lr)
    i = 1
    n = 1
    while i <= 13
        if lr[i]
            n = n*2
        else
            n = n*2+1
        end
        i += 1
    end
    n - (2^13 - 1)
end

function get_outcome_prob(i)
    lr_index = get_lr(i)
    branch = get_branch(lr_index)

    p = 1.0
    for (g,lr) in zip(branch,lr_index)
        pw_t1 = GAME_PROBS[g]
        if lr
            p = p * pw_t1
        else
            p = p * (1.0 - pw_t1)
        end
    end
    p
end

OUTCOME_PROBS = get_outcome_prob.(1:8192)
#sum(OUTCOME_PROBS)

function get_winners(i)
    lr_index = get_lr(i)
    branch = get_branch(lr_index)
    winners = zeros(Int,13)

    for (i,g,lr) in zip(1:13,branch,lr_index)
        if lr
            winners[i] = PLAYOFFS[g][1]
        else
            winners[i] = PLAYOFFS[g][2]
        end
    end
    winners
end

function count_same(v1,v2)
    count = 0
    for a=v1
        for b=v2
            if a==b 
                count += 1
                break
            end
        end
    end
    count
end

function get_score(pick,real)
    score = 0
    score += 1 * count_same(real[1:6],  pick[1:6])
    score += 2 * count_same(real[7:10], pick[7:10])
    score += 4 * count_same(real[11:12],pick[11:12])
    score += 8 * count_same(real[13:13],pick[13:13])
    
    score
end

function get_score_mat()
    if isfile("score_matrix.csv")
        score_mat = readdlm("score_matrix.csv", ',', Int)
    else
        score_mat = zeros(Int, 2^13, 2^13)
        for i = 1:2^13
            println(i)
            picks = get_winners(i)
            Threads.@threads for j = 1:2^13
                reals = get_winners(j)
                score = get_score(picks, reals)
                score_mat[i,j] = score
            end
        end

        # writedlm( "score_matrix.csv",  score_mat, ',')
    end
    score_mat
end

SCORE_MAT = get_score_mat()





## Selection models to get SELECTION_PROBS

# Against the favorite for x[1]:x[2] games
function pick_against(x)
    num_rand = rand(x[1]:x[2])
    game_i = sort(sample(1:13, num_rand, replace = false))
    picks = trues(13)
    g = 1
    n = 1
    for i in 1:13
        pw_t1 = GAME_PROBS[g]

        if n>num_rand || i == game_i[n] #this is a flip pick
            if pw_t1 > 0.5 
                pick = false
            else
                pick = true
            end
            n += 1
        else
            if pw_t1 > 0.5 
                pick = true
            else
                pick = false
            end
        end

        if pick
            picks[i] = true
            g = g*2
        else
            picks[i] = false
            g = g*2 + 1
        end
    end
    picks
end
# N = 100000
# picks = [get_branch_num(pick_against(3)) for _ in 1:N]
# pick_freq = [count(picks.==i)/N for i in 1:2^13]
# histogram(picks)

function p_shift(x)
    picks = trues(13)
    g = 1
    for i in 1:13
        pw_t1 = GAME_PROBS[g] + x * randn() #shift the probability by randn * stdev

        if pw_t1 > 0.5 
            picks[i] = true
            g = g*2
        else
            picks[i] = false
            g = g*2 + 1
        end

    end
    picks
end

function extremeP(p,a)
    p^a / (p^a + (1-p)^a)
end

function favorite_team(x)
    t_win = x[1]
    a = x[2]
    
    picks = trues(13)
    g = 1
    for i in 1:13
        
        teams = PLAYOFFS[g]

        if teams[1] == t_win
            pick = true
        elseif teams[2] == t_win
            pick = false
        else #then extremify the odds and pick
            pw_t1 = GAME_PROBS[g]
            p = extremeP(pw_t1, a)
            if p > rand()
                pick = true
            else
                pick = false
            end
        end
       
        if pick
            picks[i] = true
            g = g*2
        else
            picks[i] = false
            g = g*2 + 1
        end
    end
    picks
end

function extremify(a)
    picks = trues(13)
    g = 1
    for i in 1:13
        pw_t1 = GAME_PROBS[g]
        p = extremeP(pw_t1, a)
        if p > rand()
            picks[i] = true
            g = g*2
        else
            picks[i] = false
            g = g*2 + 1
        end
    end
    picks
end


MODELS = [
    ("Mo",     :pick_against,  (1,3)),
    ("Dustin", :p_shift,       0.1),
    ("Akhil",  :p_shift,       0.2),
    ("David",  :favorite_team, (3,3.0)),
    ("Ben",    :pick_against,  (1,3)),
    ("Eric",   :extremify,     2.0),
    ("Steve",  :pick_against,  (1,3)),
    ("Erik",   :extremify,     1.0),
    ("Sean",   :extremify,     0.5),
]



PICK_PROBS = []
for model in MODELS
    name = model[1]
    mode = model[2]
    parm = model[3]

    N = 100000

    f_dispatch = Dict(
        :pick_against  => pick_against,
        :p_shift       => p_shift,
        :favorite_team => favorite_team,
        :extremify     => extremify
    )

    f = f_dispatch[mode]
    picks = [get_branch_num(f(parm)) for _ in 1:N]
    pick_prob = [count(picks.==i)/N for i in 1:2^13]

    push!(PICK_PROBS, pick_prob)
end

PP_TOT = [sum([pp[i] for pp in PICK_PROBS]) for i=1:8192]

# function mc_run()

#     #get everyone elses picks
#     picks = [sample(1:2^13, Weights(pp)) for pp in PICK_PROBS]

#     #now how would all the picks have stacked up against these?
#     pos = zeros(Float64, 2^13)
#     for p in 1:2^13 #Possible picks
#         println(p)
#         for o in 1:2^13
#             my_score = SCORE_MAT[p,o]
#             tied = 1
#             win = true
#             for pick in picks
#                 other_score = SCORE_MAT[pick, o]
#                 if other_score > my_score #then I don't win with this outcome
#                     win = false
#                     break
#                 elseif other_score == my_score
#                     tied += 1
#                 end
#             end
#             if win
#                 pos[p] += OUTCOME_PROBS[p] / tied
#             end
#         end
#     end

#     pos
# end

# pos = mc_run()


PICKN_PROB = zeros(Float64, 2^13, length(MODELS)+1)
for i = 1:2^13
    println(i)
    pi = [pp[i] for pp in PICK_PROBS]
    pb = PoissonBinomial(pi)
    for j = 0:length(MODELS)
        PICKN_PROB[i,j+1] = pdf(pb, j)
    end
end

#Now what is expected value for each pick I can make?
ev = zeros(Float64, 2^13)
Threads.@threads for p = 1:2^13
# for p = 1:2^13
    println(count(ev.==0.0))
    
    EV_win = 0.0
    EV_tie = 0.0
    for o = 1:2^13
        my_score = SCORE_MAT[p,o]
        chance_this_o  = OUTCOME_PROBS[o]

        #Chance I win = probability that nobody is in anything higher than me
        picks_I_beat = my_score .>  SCORE_MAT[:,o]
        p_beat_players = [sum(pp[picks_I_beat]) for pp in PICK_PROBS]
        chance_I_win = prod(p_beat_players) #Need to beat all the people to win
        EV_win += chance_I_win * chance_this_o

        #Chance I tie 
        picks_I_tie = my_score .==  SCORE_MAT[:,o]
        p_tie_players = [sum(pp[picks_I_tie]) for pp in PICK_PROBS]
        picks_I_lose = my_score .<  SCORE_MAT[:,o]
        p_lose_players = [sum(pp[picks_I_lose]) for pp in PICK_PROBS]
        chance_I_lose = 1. - prod(1.0 .- p_lose_players)


        #What are chances I tie one and beat all the others?
        p_tie_one = 0.0
        for i in 1:length(p_beat_players)
            if p_beat_players[i] > 0
                p_tie_one += p_tie_players[i] * prod(p_beat_players)/p_beat_players[i]
            end
        end

        p_tie_two = 0.0
        for i in 1:length(p_beat_players)
            for j in i+1:length(p_beat_players)
                if p_beat_players[i] > 0 && p_beat_players[j] > 0
                    p_tie_two += p_tie_players[i] * p_tie_players[j] * prod(p_beat_players)/p_beat_players[i]/p_beat_players[j]
                end
            end
        end

        p_tie_three = 0.0
        for i in 1:length(p_beat_players)
            for j in i+1:length(p_beat_players)
                for k in j+1:length(p_beat_players)
                    if p_beat_players[i] > 0 && p_beat_players[j] > 0 && p_beat_players[k] > 0
                        p_tie_three += p_tie_players[i] * p_tie_players[j] * p_tie_players[k] * prod(p_beat_players)/p_beat_players[i]/p_beat_players[j]/p_beat_players[k]
                    end
                end
            end
        end

        EV_tie += (p_tie_one/2 + p_tie_two/3 + p_tie_three/4) * chance_this_o

    end
    ev[p] = EV_win + EV_tie
end
writedlm("ev_02.csv",  ev, ',')
plot(ev)

println("Best chance of winning: ", round(maximum(ev)*100, digits=2), "%")
idx = argmax(ev)
lr = get_lr(idx)
branch = get_branch(lr)

println("Make these picks: ")
for (d,g) in zip(lr,branch)
    t1 = TEAMS[PLAYOFFS[g][1]][1]
    t2 = TEAMS[PLAYOFFS[g][2]][1]
    if d 
        println(t1, " ", round(GAME_PROBS[g]*100),"% over ", t2, " ", round((1-GAME_PROBS[g])*100), "%")
    else
        println(t2, " ", round((1-GAME_PROBS[g])*100), "% over ", t1, " ", round(GAME_PROBS[g]*100), "%")
    end
end



get_game_prob(11, 12, 3)
## Check against https://projects.fivethirtyeight.com/2021-nfl-predictions/
# 1  => ("TEN", 1590, (36.166461, -86.771289)),
# 2  => (" KC", 1689, (39.048914, -94.484039)),
# 3  => ("BUF", 1637, (42.773739, -78.786978)),
# 4  => ("CIN", 1570, (39.095442, -84.516039)),
# 5  => (" LV", 1480, (37.751411,-122.200889)),
# 6  => ("NE",  1571, (42.090925, -71.264350)),
# 7  => ("PIT", 1486, (40.446786, -80.015761)),

# 11 => (" GB", 1680, (44.501306, -88.062167)),
# 12 => (" TB", 1654, (27.975967, -82.503350)),
# 13 => ("DAL", 1636, (32.747778, -97.092778)),
# 14 => ("LAR", 1591, (38.632975, -90.188547)),
# 15 => ("ARI", 1523, (33.527700,-112.262608)),
# 16 => (" SF", 1580, (37.713486,-122.386256)),
# 17 => ("PHI", 1508, (39.900775, -75.167453)),

# sum([OUTCOME_PROBS[i] for i in 1:2^13 if get_winners(i)[end]==7])