# Who made it to playoffs, and how good are they?
AFC = [
    "KC"    1711
    "BUF"   1682
    "PIT"   1578
    "TEN"   1572
    "BAL"   1651
    "CLE"   1578
    "IND"   1594
]

NFC = [
    "GB"    1675
    "NO"    1731
    "SEA"   1620
    "WSH"   1453
    "TB"    1618
    "LAR"   1591
    "CHI"   1497
]

# Where is superbowl played?
SUPERBOWL_LOC = "TB"

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
    println(game_i)
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
teams = [get_teams(i, teams) for i in 2^0:2^6-1]
append!(teams, [get_teams(i, teams) for i in 2^6:2^10-1])
append!(teams, [get_teams(i, teams) for i in 2^10:2^12-1])
append!(teams, [get_teams(i, teams) for i in 2^12:2^13-1])

