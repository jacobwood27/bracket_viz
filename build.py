import json

HTML_TEMPLATE = r"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Bracketry</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

<!-- Picks Table Placeholder -->
<div class="tree" style="position:absolute; z-index:10;">
    <ul>
        <li>
            <a class="tooltip">
                PICKS
                <span class="tabletext">
                    <table id="picks-table">
                        <!-- Dynamically filled by build_bracket.js -->
                    </table>
                </span>
            </a>
        </li>
    </ul>
</div>

<!-- Bracket Placeholder -->
<div class="tree" id="bracket-root">
    <!-- Dynamically built by build_bracket.js -->
</div>

<script src="build_bracket.js"></script>
</body>
</html>
"""

JS_TEMPLATE = r"""// build_bracket.js
//
// Dynamically loads big_dic.json, then builds the table of picks
// and the entire bracket tree (with tooltip info, hide/show toggles, etc.).

// We’ll replicate the same logic from the Julia code.

function click_played_games() {
    // Same logic as your original cC calls in Julia’s <script>:
    // Toggling matches that have been played, etc.
    // Adjust to match your real usage or simply leave it for an example:
    cC("2", "1L");
    document.getElementById("1L").parentElement.classList.add("locked");

    cC("4", "2L");
    document.getElementById("2L").parentElement.classList.add("locked");

    cC("8", "4L");
    document.getElementById("4L").parentElement.classList.add("locked");

    cC("16", "8L");
    document.getElementById("8L").parentElement.classList.add("locked");

    cC("33", "16R");
    document.getElementById("16R").parentElement.classList.add("locked");
}

function cC(childId, buttonId) {
    // Mimics your original toggle logic
    const buttonElem = document.getElementById(buttonId);
    buttonElem.classList.toggle("green");

    const childElem = document.getElementById(childId);
    childElem.classList.toggle("hide");

    // Check siblings
    const siblings = childElem.parentElement.childNodes;
    let hiddenCount = 0;
    for (let i = 0; i < siblings.length; i++) {
        if (siblings[i].tagName === 'LI') {
            if (siblings[i].classList.contains('hide')) {
                hiddenCount++;
            }
        }
    }
    if (hiddenCount === 0) {
        for (let i = 0; i < siblings.length; i++) {
            if (siblings[i].tagName === 'LI') {
                siblings[i].classList.add('pp');
                siblings[i].classList.remove('p');
            }
        }
    } else {
        for (let i = 0; i < siblings.length; i++) {
            if (siblings[i].tagName === 'LI') {
                siblings[i].classList.remove('pp');
                siblings[i].classList.add('p');
            }
        }
    }
}

function buildPicksTable(picksData) {
    // picksData is an array of [username, picks] similar to the original
    // big_dic["picks"] structure: [ [<name>, [NW1, NW2, ..., SB]], ... ]
    const table = document.getElementById('picks-table');
    // Build the table header
    const headerRow = document.createElement('tr');
    const blankTh = document.createElement('th');
    blankTh.textContent = "";
    headerRow.appendChild(blankTh);

    // We assume each user has a list of picks, e.g. 13 picks: NW1, NW2, etc.
    // If you have the exact labels, put them here:
    const pickLabels = ["NW1","NW2","NW3","AW1","AW2","AW3","ND1","ND2","AD1","AD2","NFC","AFC","SB"];
    pickLabels.forEach(lbl => {
        const th = document.createElement('th');
        th.textContent = lbl;
        headerRow.appendChild(th);
    });
    table.appendChild(headerRow);

    // Now fill rows
    picksData.forEach(item => {
        const [name, picksArray] = item;
        const row = document.createElement('tr');

        // Name cell
        const nameTd = document.createElement('td');
        nameTd.textContent = name;
        row.appendChild(nameTd);

        // Picks cells
        picksArray.forEach(p => {
            const td = document.createElement('td');
            td.textContent = p;
            row.appendChild(td);
        });

        table.appendChild(row);
    });
}

function rightTooltip(i, bigDic) {
    // Reproduce your right_tooltip logic
    // bigDic["right"][i], bigDic["names"], etc.
    // Return HTML string
    let s = "<table>";
    s += "<tr>";
    s += "<th>Name</th><th>Total</th>";
    // If i < 2^12, show left/right
    if (parseInt(i) < Math.pow(2, 12)) {
        s += "<th>Left</th><th>Right</th>";
    }
    s += "</tr>";

    const probs = bigDic["right"][i];
    if (parseInt(i) < Math.pow(2, 12)) {
        // also get left(i), right(i)
        const leftKey = (2 * parseInt(i)).toString();
        const rightKey = (2 * parseInt(i) + 1).toString();
        const probsL = bigDic["right"][leftKey];
        const probsR = bigDic["right"][rightKey];
        
        // Sort by descending prob
        // We'll create an array of [teamIndex, probability], then sort
        const combined = probs.map((val, idx) => [idx, val]);
        combined.sort((a,b) => b[1] - a[1]); // descending

        combined.forEach(([teamIdx, val]) => {
            const percentTotal = Math.round(val * 100) + "%";
            const percentL = Math.round(probsL[teamIdx] * 100) + "%";
            const percentR = Math.round(probsR[teamIdx] * 100) + "%";
            s += `<tr><td>${bigDic["names"][teamIdx]}</td><td>${percentTotal}</td><td>${percentL}</td><td>${percentR}</td></tr>`;
        });
    } else {
        // sort just by "probs"
        const combined = probs.map((val, idx) => [idx, val]);
        combined.sort((a,b) => b[1] - a[1]); 
        combined.forEach(([teamIdx, val]) => {
            s += `<tr><td>${bigDic["names"][teamIdx]}</td><td>${Math.round(val*100)}%</td></tr>`;
        });
    }
    s += "</table>";
    return s;
}

function leftTooltip(i, bigDic) {
    // original left_tooltip
    const prob = Math.round(bigDic["left"][i] * 100);
    const teams = bigDic["main"][i];
    return `${teams[0]}: ${prob}%  <br /> ${teams[1]}: ${100 - prob}%`;
}

function winText(i, bigDic) {
    // original win_text
    // i - (2^13 - 1) used in the original Julia code
    // bigDic["scores"][i - (2^13 - 1)]
    const offset = Math.pow(2, 13) - 1;
    const idx = i - offset;
    const scores = bigDic["scores"][idx];
    // sort by descending scores
    const combined = scores.map((val, i) => [i, val]);
    combined.sort((a,b) => b[1] - a[1]);
    let s = "";
    combined.forEach(([teamIdx, val]) => {
        s += `${bigDic["names"][teamIdx]}: ${val} <br />`;
    });
    return s;
}

function addLines(ulElem, i, bigDic) {
    // Recursively build the <li> structure
    // i is current node index

    // Create <li> tag
    const li = document.createElement('li');
    li.id = i.toString();

    if (i === 1) {
        // top node is not hidden
        li.classList.remove('hide');
    } else {
        // other nodes start hidden
        li.classList.add('hide');
    }

    if (i < Math.pow(2, 13)) {
        // internal node
        const teams = bigDic["main"][i];
        // Create <a> with tooltip
        const a = document.createElement('a');
        a.classList.add('tooltip');

        // The clickable <b> for left vs right
        const leftB = document.createElement('b');
        leftB.textContent = teams[0];
        leftB.id = i.toString() + "L";
        leftB.onclick = function() {
            cC((2*i).toString(), leftB.id);
        };

        const rightB = document.createElement('b');
        rightB.textContent = teams[1];
        rightB.id = i.toString() + "R";
        rightB.onclick = function() {
            cC((2*i + 1).toString(), rightB.id);
        };

        // Right tooltip
        const spanRight = document.createElement('span');
        spanRight.classList.add('righttt');
        spanRight.innerHTML = rightTooltip(i.toString(), bigDic);

        // Left tooltip
        const spanLeft = document.createElement('span');
        spanLeft.classList.add('lefttt');
        spanLeft.innerHTML = leftTooltip(i.toString(), bigDic);

        // Put them together
        a.appendChild(leftB);
        a.appendChild(document.createTextNode(" v "));
        a.appendChild(rightB);
        a.appendChild(spanRight);
        a.appendChild(spanLeft);

        li.appendChild(a);

        // Recurse
        const subUl = document.createElement('ul');
        li.appendChild(subUl);
        if (2*i < Math.pow(2, 14)) {
            addLines(subUl, 2*i, bigDic);
            addLines(subUl, 2*i + 1, bigDic);
        }
    } else {
        // leaf node (the final result)
        const a = document.createElement('a');
        a.innerHTML = winText(i, bigDic);
        li.appendChild(a);
    }

    ulElem.appendChild(li);
}

function buildBracket(bigDic) {
    // Start at i=1, build the entire tree up to 2^(13+1)-1
    // We'll attach it to #bracket-root
    const bracketRoot = document.getElementById('bracket-root');

    // Create the outer <ul>
    const outerUl = document.createElement('ul');
    bracketRoot.appendChild(outerUl);

    // Recursively build
    addLines(outerUl, 1, bigDic);
}

// On page load, fetch big_dic.json and build everything
window.addEventListener('DOMContentLoaded', () => {
    fetch('big_dic.json')
        .then(resp => resp.json())
        .then(bigDic => {
            // Build picks table
            buildPicksTable(bigDic["picks"]);
            // Build bracket
            buildBracket(bigDic);

            // Simulate clicking played games (optional)
            click_played_games();
        })
        .catch(err => console.error(err));
});
"""

def main():
    # Optionally load big_dic.json here if you want to do anything with it
    # server-side. But for minimal final HTML size, we won't embed the data:
    # with open("big_dic.json", "r") as f:
    #     big_dic = json.load(f)
    
    # Write index.html
    with open("index.html", "w", encoding="utf-8") as f:
        f.write(HTML_TEMPLATE)
    print("Wrote index.html")

    # Write build_bracket.js
    with open("build_bracket.js", "w", encoding="utf-8") as f:
        f.write(JS_TEMPLATE)
    print("Wrote build_bracket.js")

if __name__ == "__main__":
    main()
