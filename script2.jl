using Plots

## Inputs for these playoffs
TEAMS = Dict(
    1 => "Chiefs",
    2 => "Bills",  
    3 => "Steelers", 
    4 => "Titans",        
    5 => "Ravens",     
    6 => "Browns", 
    7 => "Colts",
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

GAMES = [[ 2,  7],
         [13, 16],
         [14, 15],
         [ 4,  5],
         [12, 17],
         [ 3,  6]]

Wins = [2, 16, 15, 5, 12, 6]


## Couple of helpers
function get_precs(r,c)
    precs = [c]
    for i in 1:r-2
        if isodd(c)
            c+=1
        end
        c = c÷2
        pushfirst!(precs,c)
    end
    return precs
end

function get_score(picks, wins)
    #Score 1 for wildcards, 2 for next round, 4 for next, 8 for superbowl
    rd1 = 1 * length(findall(in(wins[1:6]), picks[1]))
    rd2 = 2 * length(findall(in(wins[7:10]), picks[2]))
    rd3 = 4 * length(findall(in(wins[11:12]), picks[3]))
    rd4 = 8 * length(findall(in(wins[13]), picks[4]))

    rd1 + rd2 + rd3 + rd4
end


## Add the games one row at a time
# First Game
ROWS_W = [GAMES[1]]

# Rest of Wildcards
for G in GAMES[2:end]
    push!(ROWS_W, repeat(G,length(ROWS_W[end])))
end

#Divisional Games
#First is AFC game, where Packers play the weakest link from games 2,3,5
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(7,ii)
    A_wins = [ROWS_W[2][coords[2]],ROWS_W[3][coords[3]],ROWS_W[5][coords[5]]]
    worst_team = maximum(A_wins)
    append!(tr,[11,worst_team])
end
push!(ROWS_W, tr)

#Then NFC game, where the two highest ranked winners from games 1,4,6 play each other
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(8,ii)
    N_wins = [ROWS_W[1][coords[1]],ROWS_W[4][coords[4]],ROWS_W[6][coords[6]]]
    best_teams = partialsort!(N_wins,1:2)
    append!(tr,best_teams)
end
push!(ROWS_W, tr)

#Then NFC game, where Chiefs play worst seed from 1,4,6
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(9,ii)
    N_wins = [ROWS_W[1][coords[1]],ROWS_W[4][coords[4]],ROWS_W[6][coords[6]]]
    worst_team = maximum(N_wins)
    append!(tr,[1,worst_team])
end
push!(ROWS_W, tr)

#Then AFC game, where the two highest ranked winners from games 2,3,5 play each other
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(10,ii)
    A_wins = [ROWS_W[2][coords[2]],ROWS_W[3][coords[3]],ROWS_W[5][coords[5]]]
    best_teams = partialsort!(A_wins,1:2)
    append!(tr,best_teams)
end
push!(ROWS_W, tr)


# Conference Champs
# NFC First - this will be winners of games 8 and 9
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(11,ii)
    N_wins = [ROWS_W[8][coords[8]],ROWS_W[9][coords[9]]]
    append!(tr,N_wins)
end
push!(ROWS_W, tr)

# Then AFC
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(12,ii)
    A_wins = [ROWS_W[7][coords[7]],ROWS_W[10][coords[10]]]
    append!(tr,A_wins)
end
push!(ROWS_W, tr)


#Superbowl
# Then Superbowl - winners of games 11 and 12
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(13,ii)
    S_wins = [ROWS_W[11][coords[11]],ROWS_W[12][coords[12]]]
    append!(tr,S_wins)
end
push!(ROWS_W, tr)



## Let's see how everyone scores across the bottom
winning_pickers = []
winning_scores = []
for ii in 1:length(ROWS_W[end])
    crds = get_precs(14,ii)
    wins = [ROWS_W[jj][kk] for (jj,kk) in enumerate(crds)]

    picker = []
    best_score = 0
    for (guy, picks) in PICKS
        score = get_score(picks, wins)
        if score > best_score
            picker = [guy]
            best_score = score
        elseif score == best_score
            push!(picker, guy)
        end
    end
    
    push!(winning_pickers, picker)
    push!(winning_scores, best_score)
end


## Make the Plot
gr()
p = plot([0],[0], legend=false, xlims = [0,8193], ylims = [-4,27], xticks=:none, yticks=:none);

Xp = 1:length(ROWS_W[end])
Yp = collect(Xp) .* 0 .+ 0
annotate!(p, [(x, y, text(string(scr), 6, :center)) for (x,y,scr) in zip(Xp,Yp,winning_scores)]);

X_nms = []
Y_nms = []
T_nms = []
for ii in 1:length(Xp)
    println(ii)
    nms = winning_pickers[ii]
    Yp = collect(range(-0.5, step=-0.3, length=length(nms)))
    X = Yp .*0 .+ Xp[ii]
    append!(X_nms, X)
    append!(Y_nms, Yp)
    append!(T_nms, nms)
end
annotate!(p, [(x,y,Plots.text(nam, 6, :center)) for (x,y,nam) in zip(X_nms,Y_nms,T_nms)]);

Xp = 1:length(ROWS_W[end])
Yp = collect(Xp) .* 0 .+ 1
annotate!(p, [(x,y,Plots.text(TEAMS[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[end])]);

Xpb = Xp
Ypb = Yp

Xp = range(1.5, step = 2, length = length(ROWS_W[end]) ÷ 2)
Yp = collect(Xp).*0 .+ 2
Tp = [TEAMS[ROWS_W[end][ii]] * " vs. " * TEAMS[ROWS_W[end][ii+1]] for ii in 1:2:length(ROWS_W[end])]
annotate!(p, [(x,y,Plots.text(t, 6, :center)) for (x,y,t) in zip(Xp,Yp,Tp)]);

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
    annotate!(p, [(x,y,Plots.text(TEAMS[i], 6, :center)) for (x,y,i) in zip(Xp,Yp,ROWS_W[rr])]);

    counter += 1
    Xpn = []
    for ii in 1:2:length(Xp)
        push!(Xpn, Xp[ii] + 1/2*(Xp[ii+1]-Xp[ii]))
    end
    Xp = Xpn
    Yp = collect(Xp) .* 0 .+ counter
    Tp = [TEAMS[ROWS_W[rr][ii]] * " vs. " * TEAMS[ROWS_W[rr][ii+1]] for ii in 1:2:length(ROWS_W[rr])]
    annotate!(p, [(x,y,Plots.text(t, 6, :center)) for (x,y,t) in zip(Xp,Yp,Tp)]);

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

plot!(p, size=(400000,1500));
savefig(p, pwd()*"/test.svg");