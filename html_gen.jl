using JSON

top = """
<!DOCTYPE html>
<html>

<head>
 <meta charset="utf-8">
 <title>My test page</title>
 <link rel="stylesheet" href="styles.css">
</head>

<body>
<div class="tree">
<ul>
"""

bot = """
</ul>
</body>

<script type="text/javascript">
 function cC(id) {
  var element = document.getElementById(id);
  element.classList.toggle("hide");
 }
 document.addEventListener("DOMContentLoaded", function(){
    cC("2");
    cC("4");
    cC("8");
    cC("16");
    cC("32");
    cC("64");
    cC("128");
    cC("256");
    cC("512");
    cC("1024");
    cC("2049");
    cC("4098");
});
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




function main_text(i::Int)
    teams = BIG_DIC["main"]["$i"]
    teams[1] * " v " * teams[2]
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



function add_lines!(v, i::Int)

    if i < 2^13
        push!(v, "<li>")
        push!(v, "<a onclick=\"cC('$i')\" class=\"tooltip\">")
        push!(v, main_text(i))#DEN v LAC
        push!(v, "<span class=\"tooltiptext\">")
        push!(v, right_tooltip(i))#Testhover $i <br /> line2 - $i
        push!(v, "</span>")
        push!(v, "<span class=\"tooltiptext2\">")
        push!(v, left_tooltip(i))#Lefttext <br /> line2 - 1
        push!(v, "</span></a>")
    else
        push!(v, "<li>")
        push!(v, "<a>")
        push!(v, win_text(i))#DEN v LAC
        push!(v, "</a>")
    end

    if i > 1
        push!(v, "<ul id=\"$i\" class=\"hide\">")
    else
        push!(v, "<ul id=\"$i\">")
    end
    if left(i) < 2^(levels + 1)
        add_lines!(v, left(i))
        add_lines!(v, right(i))
    end
    push!(v, "</ul>")
    push!(v, "</li>")

end


mid_lines = String[]
add_lines!(mid_lines, 1)

open("index.html", "w") do file
    write(file, top)
    [write(file, l * "\n") for l in mid_lines]
    write(file, bot)
end