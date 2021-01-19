using Plots
using Plots.PlotMeasures
using DataStructures

WINS = [2, 16, 15, 5, 12, 6, 11, 2, 1, 15]

TEAMS = Dict(
    #AFC Teams
    1 => "Chiefs",
    2 => "Bills",  
    3 => "Steelers", 
    4 => "Titans",        
    5 => "Ravens",     
    6 => "Browns", 
    7 => "Colts",
    #NFC Teams
    11 => "Packers", 
    12 => "Saints", 
    13 => "Seahawks", 
    14 => "Football Team", 
    15 => "Buccaneers", 
    16 => "Rams",   
    17 => "Bears"
)

#Change these to QB Elos
ELOS = Dict(
    #AFC Teams
    1 => 1712.65,
    2 => 1693.22,
    3 => 1572.16,
    4 => 1599.08,
    5 => 1654.22,
    6 => 1516.98,
    7 => 1597.06,
    #NFC Teams
    11 => 1700.23,
    12 => 1695.68,
    13 => 1628.77,
    14 => 1456.95,
    15 => 1630.47,
    16 => 1587.86,
    17 => 1500.12
)

PICKS = OrderedDict(
    "Akhil" => [15, 13, 12, 5, 3, 2, 11, 12, 1, 2, 11, 2, 2],
    "Steve" => [15, 13, 12, 4, 3, 2, 11, 12, 1, 2, 11, 2, 2],
    "Dustin"=> [15, 13, 12, 5, 3, 2, 11, 12, 1, 2, 12, 1, 1],
    "Jacob" => [15, 13, 12, 5, 3, 2, 11, 12, 1, 2, 12, 1, 1],
    "David" => [15, 16, 12, 4, 3, 2, 11, 15, 1, 2, 11, 2, 2],
    "Eric"  => [15, 13, 12, 5, 3, 2, 15, 12, 1, 2, 12, 1, 1],
    "Mo"    => [15, 16, 12, 5, 6, 2, 11, 15, 1, 2, 11, 1, 1],
    "Ben"   => [15, 13, 12, 5, 3, 2, 15, 12, 5, 2, 12, 2, 2],
    "Theory"=> [7,  16, 15, 4, 17,6, 11,  4, 7, 16, 4, 11,11]
)

struct Game
    team1::Int8
    team2::Int8
end
Game(X::Vector) = Game(X[1],X[2])
get_anno(g::Game) = TEAMS[g.team1] * " vs. " * TEAMS[g.team2]
get_plot_anno(g::Game) = TEAMS[g.team1] * "\n" * TEAMS[g.team2]

get_teams(g::Game) = [g.team1, g.team2]

WC_GAMES = [Game( 2,  7),
            Game(13, 16),
            Game(14, 15),
            Game( 4,  5),
            Game(12, 17),
            Game( 3,  6)]

row_idxs(row_num) = 2^(row_num-1):2^(row_num)-1
parent_idx(idx) = idx > 1 ? floor(idx÷2) : 0
function get_winners(idx, gtree) 
    if idx == 1
        return Int8[]
    elseif iseven(idx)
        return [get_winners(parent_idx(idx), gtree); gtree[parent_idx(idx)].team1]
    else
        return [get_winners(parent_idx(idx), gtree); gtree[parent_idx(idx)].team2]
    end
end

function get_prob(idx, gtree; root_node=1) #Probability of getting to this idx is product of all previous probabilities
    if idx == root_node #means we can walk back to something that happened
        return 1
    elseif idx < root_node #means we walk back past a thing that happened, and multiply everything downstream by 0
        return 0
    elseif iseven(idx)
        return Pwin(gtree[parent_idx(idx)]) * get_prob(parent_idx(idx), gtree, root_node=root_node)
    else
        return (1.0-Pwin(gtree[parent_idx(idx)])) * get_prob(parent_idx(idx), gtree, root_node=root_node)
    end
end

function get_row(idx)
    for n = 1:13
        if 2^n > idx
            return n
        end
    end
end

function get_coords(idx)
    row = get_row(idx)
    n_els = 2^(row-1)
    ss = 1/n_els
    ns = idx - n_els
    col = ss/2 + ns * ss
    # col = (idx - 2^(row-1) + 1)/(2^(row-1)+1)
    return [row,col]
end

function get_actual_idx(wins,GTREE)
    idx = 1
    for w in wins
        if GTREE[idx].team1 == w
            idx = 2*idx
        elseif GTREE[idx].team2 == w
            idx = 2*idx + 1
        else
            error("Wrong team in wins vector")
        end
    end
    idx
end

Pwin(A,B) = 1/(10^(1.2*(B-A)/400)+1) #straight ELO probabilities, the 1.2 is in there for playoff games. I'll skip home team stuff for now https://fivethirtyeight.com/methodology/how-our-nfl-predictions-work/
Pwin(G) = Pwin(G.team1,G.team2)


# GTREE will be big vector of games, linked structure is implied and does not need to be carried
GTREE = Game[]

# Add in the WC Games
for ii = 1:6
    [push!(GTREE, WC_GAMES[ii]) for dummy in row_idxs(ii)];
end

# Game 7 - Best NFC team (id 11) plays weakest from winners of games 2,3,5
[idx |> x->get_winners(x,GTREE)[[2,3,5]] |> maximum |> x->Game(11,x) |> x->push!(GTREE,x) for idx in row_idxs(7)];

# Game 8 - Top winning AFC wildcard teams, so lowest seed winners from games 1,4,6
[idx |> x->get_winners(x,GTREE)[[1,4,6]] |> x->partialsort!(x,1:2) |> collect |> Game |> x->push!(GTREE,x) for idx in row_idxs(8)];

# Game 9 - Best AFC team (id 1) plays weakest from winners of games 1,4,6
[idx |> x->get_winners(x,GTREE)[[1,4,6]] |> maximum |> x->Game(1,x) |> x->push!(GTREE,x) for idx in row_idxs(9)];

# Game 10 - Top winning NFC wildcard teams, so lowest seed winners from games 2,3,5
[idx |> x->get_winners(x,GTREE)[[2,3,5]] |> x->partialsort!(x,1:2) |> collect |> Game |> x->push!(GTREE,x) for idx in row_idxs(10)];

# Game 11 - AFC Championship game - this will be winners of games 8 and 9
[idx |> x->get_winners(x,GTREE)[[ 8, 9]] |> sort! |> Game |> x->push!(GTREE,x) for idx in row_idxs(11)];

# Game 12 - NFC Championship game - this will be winners of games 7 and 10
[idx |> x->get_winners(x,GTREE)[[ 7,10]] |> sort! |> Game |> x->push!(GTREE,x) for idx in row_idxs(12)];

# Game 13 - Superbowl - this will be winners of games 11 and 12
[idx |> x->get_winners(x,GTREE)[[11,12]] |> sort! |> Game |> x->push!(GTREE,x) for idx in row_idxs(13)];



## 
p = plot([0],[0], legend=false, xlims = [0,15], ylims = [0,1], xticks=:none, yticks=:none);

#Write in the games
crds = get_coords.(1:length(GTREE))
annotate!(p, [(c[1],c[2],Plots.text(scr, 3, :center)) for (c,scr) in zip(crds, get_anno.(GTREE))]);

#SB winners
sb_ys = range(0,1,length=8192)
sb_wins = reduce(vcat,get_teams.(GTREE[4096:end]))
annotate!(p, [(14,y,Plots.text(TEAMS[team_num], 3, :center)) for (y,team_num) in zip(sb_ys, sb_wins)]);

#Connecting lines, with NaNs to pick up the pencil
LineX = Float64[]
LineY = Float64[]
for ii in 1:4095
    append!(LineX, [crds[2*ii+1][1],crds[ii][1],crds[2*ii][1],NaN64])
    append!(LineY, [crds[2*ii+1][2],crds[ii][2],crds[2*ii][2],NaN64])
end
for ii in 1:2:length(sb_ys)
    append!(LineX, [14.0, 13.0, 14.0, NaN])
    append!(LineY, [sb_ys[ii],(sb_ys[ii]+sb_ys[ii+1])/2,sb_ys[ii+1],NaN64])
end
plot!(p,LineX,LineY, color=:black, linealpha=0.3);


plot!(p, size=(2000,30000));
savefig(p, "test.svg");







## Let's see how everyone scores across the bottom
function get_score(picks, wins)

    rd1 = 1 * length(findall(in(wins[1:6]), picks[1:6]))
    rd2 = 2 * length(findall(in(wins[7:10]), picks[7:10]))
    rd3 = 4 * length(findall(in(wins[11:12]), picks[11:12]))
    rd4 = 8 * length(findall(in(wins[13]), picks[13]))

    rd1 + rd2 + rd3 + rd4

end

scores = zeros(Int8, 2^13, length(PICKS))
for (ii,idx) in enumerate(row_idxs(14))
    wins = get_winners(idx, GTREE)

    for (jj, picks) in enumerate(values(PICKS))
        score = get_score(picks, wins)
        scores[ii,jj] = score
    end

end
best_scores = maximum(scores,dims=2)

## And the probabilities of getting to these end states
P_ENDS = [get_prob(ii, GTREE, root_node=1) for ii in 2^13:2^14-1]


## Now we can say - go through the indexes and split the probability of getting there among everyone that picked there
P_winner = zeros(length(PICKS))
for (ii,idx) in enumerate(row_idxs(14))
    best_score = best_scores[ii]
    prob_here = P_ENDS[ii]
    people_scores = scores[ii,:]
    id_winner = people_scores .== best_score
    num_winners = count(id_winner)
    indiv_prob = prob_here / num_winners
    P_winner .+= indiv_prob .* id_winner
end

## And how does that change when we go through the games that actually happened?
rec_vec = []
for ii = 0:length(WINS)
    root_node = get_actual_idx(WINS[1:ii], GTREE)
    P_ENDS = [get_prob(ii, GTREE, root_node=root_node) for ii in 2^13:2^14-1]

    P_winner = zeros(length(PICKS))
    for (ii,idx) in enumerate(row_idxs(14))
        best_score = best_scores[ii]
        prob_here = P_ENDS[ii]
        people_scores = scores[ii,:]
        id_winner = people_scores .== best_score
        num_winners = count(id_winner)
        indiv_prob = prob_here / num_winners
        P_winner .+= indiv_prob .* id_winner
    end

    push!(rec_vec, P_winner)
end

game_idcs = []

theme(:default)
seed = colorant"blue" 
cols = distinguishable_colors(length(PICKS),seed)
xticklabs = get_plot_anno.(GTREE[[get_actual_idx(WINS[1:ii], GTREE) for ii in 1:length(WINS)]])
pushfirst!(xticklabs, get_plot_anno(GTREE[1]))
pushfirst!(xticklabs, "Initial")
plot(hcat(rec_vec...)', label=permutedims(collect(keys(PICKS))), color = cols',linewidth=2, legend=:topleft, bottom_margin = 5mm)
xticks!(1:length(xticklabs),xticklabs, rotation=60, xtickfontvalign=:center)
ylabel!("Probability after Game End")
ylims!(-0.01,0.6)


## Lets build a matrix that shows every possibility of (This pick) vs (This outcome) and the score you get
score_matrix = zeros(Int8,2^13,2^13)
final_row_idxs = row_idxs(14)
for ii = 1:2^13
    println(ii)
    pick_idx = final_row_idxs[ii]
    picks = get_winners(pick_idx, GTREE)
    for jj = 1:2^13
        win_idx = final_row_idxs[jj]
        wins = get_winners(win_idx, GTREE)
        score = get_score(picks, wins)
        score_matrix[ii,jj] = score
    end
end



## What would have been bracket with best initial probabilities, given what everyone else picked?
P_ENDS = [get_prob(ii, GTREE, root_node=1) for ii in 2^13:2^14-1]

scores = zeros(Int8, 2^13, length(PICKS))
for (ii,idx) in enumerate(row_idxs(14))
    wins = get_winners(idx, GTREE)
    for (jj, picks) in enumerate(values(PICKS))
        score = get_score(picks, wins)
        scores[ii,jj] = score
    end
end
existing_picks = [findfirst(==(30),scorecol) for scorecol in eachcol(scores)]

branch_score = zeros(2^13)
for ii in 1:2^13 #each pick that could have been made

    for jj in 1:2^13 #and each outcome that came with it

        branch_prob = P_ENDS[jj]

        scores = score_matrix[[existing_picks; ii],jj]
        best_score = maximum(scores)

        id_winner = scores .== best_score

        if id_winner[end]
            num_winners = count(id_winner)
            branch_score[ii] += branch_prob / num_winners
        end

    end

end


## What would have been bracket with best initial probabilities, given a model for bracket selection?


## And who should I root for at each game as it happened?
