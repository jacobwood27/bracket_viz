using Plots


Wins = [2, 16, 15, 5, 12, 6]

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

PICKS = Dict(
    "Akhil" => [[15, 13, 12, 5, 3, 2], [11, 12, 1, 2], [11, 2], [2]],
    "Steve" => [[15, 13, 12, 4, 3, 2], [11, 12, 1, 2], [11, 2], [2]],
    "Dustin"=> [[15, 13, 12, 5, 3, 2], [11, 12, 1, 2], [12, 1], [1]],
    "Jacob" => [[15, 13, 12, 5, 3, 2], [11, 12, 1, 2], [12, 1], [1]],
    "David" => [[15, 16, 12, 4, 3, 2], [11, 15, 1, 2], [11, 2], [2]],
    "Eric"  => [[15, 13, 12, 5, 3, 2], [15, 12, 1, 2], [12, 1], [1]],
    "Mo"    => [[15, 16, 12, 5, 6, 2], [11, 15, 1, 2], [11, 1], [1]],
    "Ben"   => [[15, 13, 12, 5, 3, 2], [15, 12, 5, 2], [12, 2], [2]]
)

struct Game
    team1::Int8
    team2::Int8
end
Game(X::Vector) = Game(X[1],X[2])
get_anno(g::Game) = TEAMS[g.team1] * " vs. " * TEAMS[g.team2]

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
        return [gtree[parent_idx(idx)].team1; get_winners(parent_idx(idx), gtree)]
    else
        return [gtree[parent_idx(idx)].team2; get_winners(parent_idx(idx), gtree)]
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
p = plot([0],[0], legend=false, xlims = [0,14], ylims = [0,1], xticks=:none, yticks=:none);

#Write in the games
annotate!(p, [(c[1],c[2],Plots.text(string(scr), 6, :center)) for (c,scr) in zip(get_coords.(1:length(GTREE)),get_anno.(GTREE))]);

#SB winners
annotate!(p, [(c[1],c[2],Plots.text(string(scr), 6, :center)) for (c,scr) in zip(get_coords.(1:length(GTREE)),get_anno.(GTREE))]);



plot!(p, size=(2000,10000));
savefig(p, "test.png");








function get_score(picks, wins; scores = Scores)

    rd1 = scores[1] * length(findall(in(wins[1:6]), picks[1]))
    rd2 = scores[2] * length(findall(in(wins[7:10]), picks[2]))
    rd3 = scores[3] * length(findall(in(wins[11:12]), picks[3]))
    rd4 = scores[4] * length(findall(in(wins[13]), picks[4]))

    rd1 + rd2 + rd3 + rd4
end


## Let's see how everyone scores across the bottom
winning_pickers = []
winning_scores = []
for ii in 1:length(ROWS_W[end])
    crds = get_precs(14,ii)
    wins = [ROWS_W[jj][kk] for (jj,kk) in enumerate(crds)]

    picker = []
    best_score = 0
    for (key, picks) in Picks
        score = get_score(picks, wins)
        if score > best_score
            picker = [key]
            best_score = score
        elseif score == best_score
            push!(picker, key)
        end
    end
    
    push!(winning_pickers, picker)
    push!(winning_scores, best_score)
end


##



p = plot([0],[0], legend=false, xlims = [0,8193], ylims = [-8,27], xticks=:none, yticks=:none);

Xp = 1:length(ROWS_W[end])
Yp = collect(Xp) .* 0 .+ 0
annotate!(p, [(x,y,Plots.text(string(scr), 6, :center)) for (x,y,scr) in zip(Xp,Yp,winning_scores)]);

X_nms = []
Y_nms = []
T_nms = []
for ii in 1:length(Xp)
    println(ii)
    nms = winning_pickers[ii]
    Yp = collect(range(-0.5, step=-0.3, length=length(nms)))
    X = Yp .*0 .+ Xp[ii]
    # annotate!(p, [(x,y,Plots.text(nam, 6, :center)) for (x,y,nam) in zip(X,Yp,nms)]);
    append!(X_nms, X)
    append!(Y_nms, Yp)
    append!(T_nms, nms)
end
annotate!(p, [(x,y,Plots.text(nam, 6, :center)) for (x,y,nam) in zip(X_nms,Y_nms,T_nms)]);

Xp = 1:length(ROWS_W[end])
Yp = collect(Xp) .* 0 .+ 1
annotate!(p, [(x,y,Plots.text(Teams[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[end])]);

Xpb = Xp
Ypb = Yp

Xp = range(1.5,step=2,length = length(ROWS_G[end]))
Yp = collect(Xp) .* 0 .+ 2
annotate!(p, [(x,y,Plots.text(Teams[i[1]] * " vs. " * Teams[i[2]], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_G[end])]);

x_tri = Float64[]
y_tri = Float64[]
for jj in 1:length(Xp)
    push!(x_tri,Xpb[2*jj-1])
    push!(x_tri,Xp[jj])
    push!(x_tri,Xpb[2*jj])
    push!(x_tri,NaN)

    push!(y_tri, 1)
    push!(y_tri, 2)
    push!(y_tri, 1)
    push!(y_tri, NaN)
end
plot!(p, x_tri, y_tri)


Xpb = Xp
Ypb = Yp

counter = 2
for rr in length(ROWS_W)-1:-1:1

    println(rr)

    counter += 1
    Xpn = []
    for ii in 1:2:length(Xp)
        push!(Xpn, Xp[ii] + 1/4*(Xp[ii+1]-Xp[ii]))
        push!(Xpn, Xp[ii] + 3/4*(Xp[ii+1]-Xp[ii]))
    end
    Xp = Xpn
    Yp = collect(Xp) .* 0 .+ counter
    annotate!(p, [(x,y,Plots.text(Teams[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[rr])]);

    counter += 1
    Xpn = []
    for ii in 1:2:length(Xp)
        push!(Xpn, Xp[ii] + 1/2*(Xp[ii+1]-Xp[ii]))
    end
    Xp = Xpn
    Yp = collect(Xp) .* 0 .+ counter
    annotate!(p, [(x,y,Plots.text(Teams[i[1]] * " vs. " * Teams[i[2]], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_G[rr])]);

    x_tri = Float64[]
    y_tri = Float64[]
    for jj in 1:length(Xp)
        push!(x_tri,Xpb[2*jj-1])
        push!(x_tri,Xp[jj])
        push!(x_tri,Xpb[2*jj])
        push!(x_tri,NaN)

        push!(y_tri, counter-2)
        push!(y_tri, counter)
        push!(y_tri, counter-2)
        push!(y_tri, NaN)
    end

    plot!(p, x_tri, y_tri)

    Xpb = Xp
    Ypb = Yp
end

# # Need to count 2,3,6,7,10,11
# Xp = []
# xc = -1
# for ii = 1:length(ROWS_W[end-1])÷2
#     xc += 3
#     push!(Xp, xc)
#     xc += 1
#     push!(Xp, xc)
# end
# Yp = collect(Xp) .* 0 .+ 3
# annotate!(p, [(x,y,Plots.text(Teams[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[end-1])]);

# Xp = range(2.5,step=4,length = length(ROWS_G[end-1]))
# Yp = collect(Xp) .* 0 .+ 4
# annotate!(p, [(x,y,Plots.text(Teams[i[1]] * " vs. " * Teams[i[2]], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_G[end-1])]);

# ##
# Xpn = []
# for ii in 1:2:length(Xp)
#     push!(Xpn, Xp[ii] + 1/4*(Xp[ii+1]-Xp[ii]))
#     push!(Xpn, Xp[ii] + 3/4*(Xp[ii+1]-Xp[ii]))
# end
# Xp = Xpn
# Yp = collect(Xp) .* 0 .+ 5
# annotate!(p, [(x,y,Plots.text(Teams[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[end-2])]);

# Xpn = []
# for ii in 1:2:length(Xp)
#     push!(Xpn, Xp[ii] + 1/2*(Xp[ii+1]-Xp[ii]))
# end
# Xp = Xpn
# Yp = collect(Xp) .* 0 .+ 6
# annotate!(p, [(x,y,Plots.text(Teams[i[1]] * " vs. " * Teams[i[2]], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_G[end-2])]);

# ##
# Xpn = []
# for ii in 1:2:length(Xp)
#     push!(Xpn, Xp[ii] + 1/4*(Xp[ii+1]-Xp[ii]))
#     push!(Xpn, Xp[ii] + 3/4*(Xp[ii+1]-Xp[ii]))
# end
# Xp = Xpn
# Yp = collect(Xp) .* 0 .+ 7
# annotate!(p, [(x,y,Plots.text(Teams[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[end-3])]);

# Xpn = []
# for ii in 1:2:length(Xp)
#     push!(Xpn, Xp[ii] + 1/2*(Xp[ii+1]-Xp[ii]))
# end
# Xp = Xpn
# Yp = collect(Xp) .* 0 .+ 8
# annotate!(p, [(x,y,Plots.text(Teams[i[1]] * " vs. " * Teams[i[2]], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_G[end-3])]);

# ##
# Xpn = []
# for ii in 1:2:length(Xp)
#     push!(Xpn, Xp[ii] + 1/4*(Xp[ii+1]-Xp[ii]))
#     push!(Xpn, Xp[ii] + 3/4*(Xp[ii+1]-Xp[ii]))
# end
# Xp = Xpn
# Yp = collect(Xp) .* 0 .+ 9
# annotate!(p, [(x,y,Plots.text(Teams[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[end-4])]);

# Xpn = []
# for ii in 1:2:length(Xp)
#     push!(Xpn, Xp[ii] + 1/2*(Xp[ii+1]-Xp[ii]))
# end
# Xp = Xpn
# Yp = collect(Xp) .* 0 .+ 10
# annotate!(p, [(x,y,Plots.text(Teams[i[1]] * " vs. " * Teams[i[2]], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_G[end-4])]);



plot!(p, size=(400000,1500));
savefig(p, "test.svg");