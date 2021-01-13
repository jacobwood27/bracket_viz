using Plots


Teams = Dict(
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

Scores = [1, 2, 4, 8]

Picks = Dict(
    "Akhil" => [[15, 13, 12, 5, 3, 2], [11, 12, 1, 2], [11, 2], [2]],
    "Steve" => [[15, 13, 12, 4, 3, 2], [11, 12, 1, 2], [11, 2], [2]],
    "Dustin"=> [[15, 13, 12, 5, 3, 2], [11, 12, 1, 2], [12, 1], [1]],
    "Jacob" => [[15, 13, 12, 5, 3, 2], [11, 12, 1, 2], [12, 1], [1]],
    "David" => [[15, 16, 12, 4, 3, 2], [11, 15, 1, 2], [11, 2], [2]],
    "Eric"  => [[15, 13, 12, 5, 3, 2], [15, 12, 1, 2], [12, 1], [1]],
    "Mo"    => [[15, 16, 12, 5, 6, 2], [11, 15, 1, 2], [11, 1], [1]],
    "Ben"   => [[15, 13, 12, 5, 3, 2], [15, 12, 5, 2], [12, 2], [2]]
)

Wins = [2, 16, 15, 5, 12, 6]


function outs(g)
    o = []
    for i in g
        push!(o,i[1])
        push!(o,i[2])
    end
    o
end

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

function get_score(picks, wins; scores = Scores)

    rd1 = scores[1] * length(findall(in(wins[1:6]), picks[1]))
    rd2 = scores[2] * length(findall(in(wins[7:10]), picks[2]))
    rd3 = scores[3] * length(findall(in(wins[11:12]), picks[3]))
    rd4 = scores[4] * length(findall(in(wins[13]), picks[4]))

    rd1 + rd2 + rd3 + rd4
end

GAMES = [[ 2,  7],
         [13, 16],
         [14, 15],
         [ 4,  5],
         [12, 17],
         [ 3,  6]]

ROWS_G = []
ROWS_W = []

# First game
push!(ROWS_G,[GAMES[1]])
push!(ROWS_W, outs(ROWS_G[end]))


# Rest of Wildcard
for G in GAMES[2:end]
    push!(ROWS_G, repeat([G],length(ROWS_G[end])*2))
    push!(ROWS_W, outs(ROWS_G[end]))
end


#Divisional Games
#First is AFC game, where Rams play the weakest link from games 2,3,5
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(7,ii)
    A_wins = [ROWS_W[2][coords[2]],ROWS_W[3][coords[3]],ROWS_W[5][coords[5]]]
    worst_team = maximum(A_wins)
    push!(tr,[11,worst_team])
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))

#Then NFC game, where the two highest ranked winners from games 1,4,6 play each other
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(8,ii)
    N_wins = [ROWS_W[1][coords[1]],ROWS_W[4][coords[4]],ROWS_W[6][coords[6]]]
    best_teams = partialsort!(N_wins,1:2)
    push!(tr,best_teams)
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))

#Then NFC game, where Chiefs play worst seed from 1,4,6
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(9,ii)
    N_wins = [ROWS_W[1][coords[1]],ROWS_W[4][coords[4]],ROWS_W[6][coords[6]]]
    worst_team = maximum(N_wins)
    push!(tr,[1,worst_team])
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))

#Then AFC game, where the two highest ranked winners from games 2,3,5 play each other
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(10,ii)
    A_wins = [ROWS_W[2][coords[2]],ROWS_W[3][coords[3]],ROWS_W[5][coords[5]]]
    best_teams = partialsort!(A_wins,1:2)
    push!(tr,best_teams)
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))


# Conference Champs
# NFC First - this will be winners of games 8 and 9
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(11,ii)
    N_wins = [ROWS_W[8][coords[8]],ROWS_W[9][coords[9]]]
    push!(tr,N_wins)
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))

# Then AFC
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(12,ii)
    A_wins = [ROWS_W[7][coords[7]],ROWS_W[10][coords[10]]]
    push!(tr,A_wins)
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))


#Superbowl
# Then Superbowl - winners of games 11 and 12
tr = []
for ii in 1:length(ROWS_W[end])
    coords = get_precs(13,ii)
    S_wins = [ROWS_W[11][coords[11]],ROWS_W[12][coords[12]]]
    push!(tr,S_wins)
end
push!(ROWS_G,tr)
push!(ROWS_W, outs(ROWS_G[end]))



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