# Who made it to playoffs, and how good are they?
TEAMS = Dict(
    1  => ("KC",  1711, (39.048914, -94.484039)),
    2  => ("BUF", 1682, (42.773739, -78.786978)),
    3  => ("PIT", 1578, (40.446786, -80.015761)),
    4  => ("TEN", 1572, (36.166461, -86.771289)),
    5  => ("BAL", 1651, (39.277969, -76.622767)),
    6  => ("CLE", 1578, (41.506022, -81.699564)),
    7  => ("IND", 1594, (39.760056, -86.163806)),
    
    11 => ("GB",  1675, (44.501306, -88.062167)),
    12 => ("NO",  1731, (29.950931, -90.081364)),
    13 => ("SEA", 1620, (47.595153, -122.33162)),
    14 => ("WSH", 1453, (38.907697, -76.864517)),
    15 => ("TB",  1618, (27.975967, -82.503350)),
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
WINS = []

#### END INPUT ####

AFC_I = 1:7
NFC_I = 11:17

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

teams = Tuple{Int,Int}[]
teams = [get_teams(i, teams) for i in 2^0:2^6-1]           #wc
append!(teams, [get_teams(i, teams) for i in 2^6:2^10-1])  #conf
append!(teams, [get_teams(i, teams) for i in 2^10:2^12-1]) #div
append!(teams, [get_teams(i, teams) for i in 2^12:2^13-1]) #sb



function get_lr(idx)
    n = idx + 8191
    c = falses(13)
    i = 13
    while n > 1
        if iseven(n)
            n = n/2
        else
            c[i] = true
            n = (n-1)/2
        end
        i-=1
    end
    c
end

function get_t1_pw(t1::Team, t2::Team, l::Location; Δelo_home=0, Δelo_rest=0, Δelo_mult=1.0)
    A_elo_base = elo(t1)
    B_elo_base = elo(t2)

    Δelo_travel = 4/1000 * (dist(l, loc(t2)) - dist(l, loc(t1)))

    elo_diff = Δelo_mult * (A_elo_base - B_elo_base + Δelo_home + Δelo_travel + Δelo_rest)

    1.0 / (1 + 10^(-elo_diff/400))
end

function get_game_prob(t1, t2, wk)
    HOME_ADV = 33
    REST_ADV = 25
    PLAYOFF_MULT = 1.2

    if wk < 4
        l = TEAMS[t1][3]
    else
        l = SUPERBOWL_LOC
    end

    t1_elo = TEAMS[t1][2]
    t2_elo = TEAMS[t2][2]

    if (wk==1) || (wk==2 && t1≠1 && t2≠11) || (wk==3) #Regular playoff games
        pw_t1 = get_pw_t1(t1, t2, l, Δelo_home=HOME_ADV, Δelo_mult=PLAYOFF_MULT)
    elseif week == 2 #Rest games for 1 seeds
        pw_t1 = get_pw_t1(t1, t2, l, Δelo_home=HOME_ADV, Δelo_rest=REST_ADV, Δelo_mult=PLAYOFF_MULT)
    elseif week == 4 #Supebowl
        pw_t1 = get_pw_t1(t1, t2, l, Δelo_mult=PLAYOFF_MULT)
    end
end

function get_prob(t1t2, i)
    println(t1t2,i)
end

probs = get_prob.(teams, 1:8191)