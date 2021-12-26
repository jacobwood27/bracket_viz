using DataFrames, CSV

struct Location
    lat::Float64
    lon::Float64
end
lat(l::Location) = l.lat
lon(l::Location) = l.lon
hav(θ) = (1.0-cos(θ))/2.0

"""
Compute approximate distance between two lat/lon points in miles.
"""
function dist(l1::Location, l2::Location; r=3960.0) 
    ϕ1 = deg2rad(lat(l1))
    ϕ2 = deg2rad(lat(l2))
    λ1 = deg2rad(lon(l1))
    λ2 = deg2rad(lon(l2))

    2r * asin(sqrt(hav(ϕ2-ϕ1) + cos(ϕ1)*cos(ϕ2)*hav(λ2-λ1)))
end


struct Team
    seed::Int
    name::String
    elo::Float64
    loc::Location
end
elo(t::Team) = t.elo
loc(t::Team) = t.loc
seed(t::Team) = t.seed

struct Game
    t1::Team
    t2::Team
    loc::Location
    week::Int
    pw_t1::Float64
    pw_t2::Float64
end
function get_pw_t1(t1::Team, t2::Team, l::Location; Δelo_home=0, Δelo_rest=0, Δelo_mult=0)
    A_elo_base = elo(t1)
    B_elo_base = elo(t2)

    Δelo_travel = 4/1000 * (dist(l, loc(t2)) - dist(l, loc(t1)))

    elo_diff = Δelo_mult * (A_elo_base - B_elo_base + Δelo_home + Δelo_travel + Δelo_rest)

    1.0 / (1 + 10^(-elo_diff/400))
end

function Game(t1::Team, t2::Team, week::Int; l=nothing)
    
    HOME_ADV = 33
    REST_ADV = 25
    PLAYOFF_MULT = 1.2

    if week < 4
        l = loc(t1)
    end

    if (week==1) || (week==2 && seed(t1)≠1) || (week==3) #Regular playoff games
        pw_t1 = get_pw_t1(t1, t2, l, Δelo_home=HOME_ADV, Δelo_mult=PLAYOFF_MULT)
    elseif week == 2 #Rest games for 1 seeds
        pw_t1 = get_pw_t1(t1, t2, l, Δelo_home=HOME_ADV, Δelo_rest=REST_ADV, Δelo_mult=PLAYOFF_MULT)
    elseif week == 4 #Supebowl
        pw_t1 = get_pw_t1(t1, t2, l, Δelo_mult=PLAYOFF_MULT)
    end

    pw_t2 = 1.0 - pw_t1

    Game(t1, t2, l, week, pw_t1, pw_t2)
end

struct Node
    val::Game
    p::Union{Node,Nothing}
    l::Union{Node,Nothing}
    r::Union{Node,Nothing}
end

struct Tree
    d::Dict{Tuple{Int64, Int64}, Node}
end
add!(T::Tree)


TEAM_LOCS = Dict(
    "ARI" => Location(33.527700, -112.262608),
    "ATL" => Location(33.757614,  -84.400972),
    "BAL" => Location(39.277969,  -76.622767),
    "BUF" => Location(42.773739,  -78.786978),
    "CAR" => Location(35.225808,  -80.852861),
    "CHI" => Location(41.862306,  -87.616672),
    "CIN" => Location(39.095442,  -84.516039),
    "CLE" => Location(41.506022,  -81.699564),
    "DAL" => Location(32.747778,  -97.092778),
    "DEN" => Location(39.743936, -105.020097),
    "DET" => Location(42.340156,  -83.045808),
    "GB"  => Location(44.501306,  -88.062167),
    "HOU" => Location(29.684781,  -95.410956),
    "IND" => Location(39.760056,  -86.163806),
    "JAX" => Location(30.323925,  -81.637356),
    "KC"  => Location(39.048914,  -94.484039),
    "LAC" => Location(32.783117, -117.119525),
    "LAR" => Location(38.632975,  -90.188547),
    "LV"  => Location(37.751411, -122.200889),
    "MIA" => Location(25.957919,  -80.238842),
    "MIN" => Location(44.973881,  -93.258094),
    "NE"  => Location(42.090925,  -71.264350),
    "NO"  => Location(29.950931,  -90.081364),
    "NYG" => Location(40.812194,  -74.076983),
    "NYJ" => Location(40.812194,  -74.076983),
    "PHI" => Location(39.900775,  -75.167453),
    "PIT" => Location(40.446786,  -80.015761),
    "SEA" => Location(47.595153, -122.331625),
    "SF"  => Location(37.713486, -122.386256),
    "TB"  => Location(27.975967,  -82.50335),
    "TEN" => Location(36.166461,  -86.771289),
    "WSH" => Location(38.907697,  -76.864517),
)

PICK_PTS = Dict(
    1 => 1, #wildcard
    2 => 2, #division
    3 => 4, #conference
    4 => 8  #superbowl
)

function Tree(PLAYOFFS::Dict{String, Vector{Tuple{String, Int64}}})
    if length(PLAYOFFS["AFC"])≠7 || length(PLAYOFFS["NFC"])≠7
        error("7 teams make playoffs in each division")
    end

    afc = [Team(i, tm[1], tm[2], TEAM_LOCS[tm[1]]) for (i,tm) in enumerate(PLAYOFFS["AFC"])]
    nfc = [Team(i, tm[1], tm[2], TEAM_LOCS[tm[1]]) for (i,tm) in enumerate(PLAYOFFS["NFC"])]

    root_game = Game(afc[2], afc[7], 1)
    root = Node(root_game, nothing, 
    add_left!(root)
    add_right!(root)

    ## Week 1 ##
    ## Game 1 - AFC 2 vs AFC 7
    g = Game(afc[2], afc[7], 1)

    ## Game 2 - NFC 3 vs NFC 6
    g = Game(nfc[3], nfc[6], 1)

    ## Game 3 - NFC 4 vs NFC 5
    g = Game(nfc[4], nfc[5], 1)

    ## Game 4 - AFC 4 vs AFC 5
    g = Game(afc[4], afc[5], 1)

    ## Game 5 - NFC 2 vs NFC 7
    g = Game(nfc[2], nfc[7], 1)

    ## Game 6 - AFC 3 vs AFC 6 
    g = Game(afc[3], afc[6], 1)

    return g
end




## Test
PLAYOFFS = Dict(
    "AFC" => [
        ("KC" , 1711)
        ("BUF", 1682)
        ("PIT", 1578)
        ("TEN", 1572)
        ("BAL", 1651)
        ("CLE", 1578)
        ("IND", 1594)
    ],
    "NFC" => [
        ("GB" , 1675)
        ("NO" , 1731)
        ("SEA", 1620)
        ("WSH", 1453)
        ("TB" , 1618)
        ("LAR", 1591)
        ("CHI", 1497)
    ],
    "SB_LOC" => "TB"
)
gametree = Tree(PLAYOFFS)