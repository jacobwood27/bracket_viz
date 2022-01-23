using JSON

top1 = """
<!DOCTYPE html>
<html>

<head>
 <meta charset="utf-8">
 <title>Bracketry</title>
 <link rel="stylesheet" href="styles.css">
</head>

<body>

<div class="tree", style="position:absolute; z-index:10;">
<ul>
    <li>
        <a class="tooltip">
            PICKS
            <span class="tabletext">
                <table>
                    <tr>
                      <th></th>
                      <th>NW1</th>
                      <th>NW2</th>
                      <th>NW3</th>
                      <th>AW1</th>
                      <th>AW2</th>
                      <th>AW3</th>
                      <th>ND1</th>
                      <th>ND2</th>
                      <th>AD1</th>
                      <th>AD2</th>
                      <th>NFC</th>
                      <th>AFC</th>
                      <th>SB</th>
                    </tr>
"""

# <th>PTS</th>
# <th>EVP</th>
# <th>MAX</th>

top2 = """
                  </table>
            </span>
        </a>
    </li>
</ul>
</div>

<div class="tree">
<ul>
"""

bot = """
</ul>
</body>

<script type="text/javascript">
    function cC(id, id2) {
        var e2 = document.getElementById(id2);
        e2.classList.toggle("green");
        var e = document.getElementById(id);
        e.classList.toggle("hide");
        var sibs = e.parentElement.childNodes;
        var hidden_sibs = 0;
        for (index = 0; index < sibs.length; index++) {
            if (sibs[index].tagName == 'LI') {
                if (sibs[index].classList.contains("hide")) {
                    hidden_sibs++
                }
            }
        }
        if (hidden_sibs == 0) {
            for (index = 0; index < sibs.length; index++) {
                if (sibs[index].tagName == 'LI') {
                    sibs[index].classList.add("pp");
                    sibs[index].classList.remove("p");
                }
            }
        } else {
            for (index = 0; index < sibs.length; index++) {
                if (sibs[index].tagName == 'LI') {
                    sibs[index].classList.remove("pp");
                    sibs[index].classList.add("p");
                }
            }
        }
    }

    function click_played_games() {
        cC("2", "1L");
        var e = document.getElementById("1L");
        e.parentElement.classList.add("locked");

        cC("4", "2L");
        var e = document.getElementById("2L");
        e.parentElement.classList.add("locked");

        cC("8", "4L");
        var e = document.getElementById("4L");
        e.parentElement.classList.add("locked");

        cC("17", "8R");
        var e = document.getElementById("8R");
        e.parentElement.classList.add("locked");

        cC("34", "17L");
        var e = document.getElementById("17L");
        e.parentElement.classList.add("locked");

        cC("68", "34L");
        var e = document.getElementById("34L");
        e.parentElement.classList.add("locked");

        cC("137", "68R");
        var e = document.getElementById("68R");
        e.parentElement.classList.add("locked");

        cC("275", "137R");
        var e = document.getElementById("137R");
        e.parentElement.classList.add("locked");
    }
    document.onload = click_played_games();
</script>

</html>
"""

levels = 13
N = 2^levels - 1

function parent(i::Int)
    if isodd(i)
        return (i - 1) / 2
    else
        return i / 2
    end
end

left(i::Int) = i * 2
right(i::Int) = i * 2 + 1

BIG_DIC = JSON.parsefile("big_dic.json")


function get_table_lines()
    picks = BIG_DIC["picks"]

    tl = []
    for pick in picks
        push!(tl, "<tr>")

        name = pick[1]
        push!(tl, "<td>$name</td>")

        for p in pick[2]
            push!(tl, "<td>$p</td>")
        end

        #PTS 
        #EVP
        #MAX

        push!(tl, "</tr>")
    end

    tl
end

NAMES = BIG_DIC["names"]
function right_tooltip(i::Int)
    s = ""
    if i < 2^12
        probs = BIG_DIC["right"]["$i"]
        probsL = BIG_DIC["right"]["$(left(i))"]
        probsR = BIG_DIC["right"]["$(right(i))"]
        sort_idx = sortperm(probs, rev = true)
        for i in sort_idx
            # s = s * NAMES[i] * ": " * string(probs[i] * 100) * "% ($(probsL[i] * 100)%, $(probsR[i] * 100)%) <br />"
            s = s * NAMES[i] * ": " * string(Int(round(probs[i] * 100))) * "% ($(Int(round(probsL[i] * 100)))%, $(Int(round(probsR[i] * 100)))%) <br />"
        end
    else
        probs = BIG_DIC["right"]["$i"]
        sort_idx = sortperm(probs, rev = true)
        for i in sort_idx
            s = s * NAMES[i] * ": " * string(Int(round(probs[i] * 100))) * "% <br />"
        end
    end
    s
end

function left_tooltip(i::Int)
    prob = Int(round(BIG_DIC["left"]["$i"] * 100))
    teams = BIG_DIC["main"]["$i"]
    "$(teams[1]): $prob%  <br /> $(teams[2]): $(100-prob)%"
end

function win_text(i::Int)
    scores = BIG_DIC["scores"]["$(i-(2^13-1))"]
    sort_idx = sortperm(scores, rev = true)
    s = ""
    for i in sort_idx
        s = s * NAMES[i] * ": " * string(scores[i]) * " <br />"
    end
    s
end

GAMES = [1]

function add_lines!(v, i::Int)

    
    if i == 1
        push!(v, "<li id=\"$i\">")
    else
        push!(v, "<li id=\"$i\" class=\"hide\">")
    end

    if i < 2^13
        # if i in GAMES
        #     push!(v, "<a onclick=\"cC('$i')\" class=\"tooltip locked\">")
        # else
        #     push!(v, "<a onclick=\"cC('$i')\" class=\"tooltip\">")
        # end
        teams = BIG_DIC["main"]["$i"]
        push!(v, """
        <a class="tooltip">
            <b onclick="cC('$(left(i))', '$(i)L')" id="$(i)L">$(teams[1])</b> v <b onclick="cC('$(right(i))', '$(i)R')" id="$(i)R">$(teams[2])</b>
            <span class=\"righttt\">$(right_tooltip(i))</span>
            <span class=\"lefttt\">$(left_tooltip(i))</span>
        </a>
        """)
    else
        push!(v, "<a>")
        push!(v, win_text(i))#DEN v LAC
        push!(v, "</a>")
    end

    
    # if i > 1
    #     push!(v, "<ul id=\"$i\" class=\"hide\">")
    # else
    #     push!(v, "<ul id=\"$i\">")
    # end

    if left(i) < 2^(levels + 1)
        push!(v,"<ul>")
        add_lines!(v, left(i))
        add_lines!(v, right(i))
        push!(v, "</ul>")
    end

    push!(v, "</li>")
    
    

end

table_lines = get_table_lines()

mid_lines = String[]
add_lines!(mid_lines, 1)

open("index.html", "w") do file
    write(file, top1)
    [write(file, l * "\n") for l in table_lines]
    write(file, top2)
    [write(file, l * "\n") for l in mid_lines]
    write(file, bot)
end