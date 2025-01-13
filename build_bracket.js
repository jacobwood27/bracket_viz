// build_bracket.js
//
// Loads big_dic.json, builds a lazy bracket: only expand relevant parts.
// Also respects "decided" games (with known winners).

function cC(childId, buttonId) {
    // The same basic toggle as before
    const buttonElem = document.getElementById(buttonId);
    if (!buttonElem) return;

    buttonElem.classList.toggle("green");

    const childElem = document.getElementById(childId);
    if (!childElem) return;

    childElem.classList.toggle("hide");

    // check siblings
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

function click_played_games() {
    // Example of automatically toggling certain games if you wish
    // Adjust to your scenario or remove if not needed
    cC("2", "1L");
    const e1 = document.getElementById("1L");
    if (e1) e1.parentElement.classList.add("locked");

    // etc... or read from "decided" to do a more robust approach
}

function buildPicksTable(picksData) {
    const table = document.getElementById('picks-table');
    // Build header
    const headerRow = document.createElement('tr');
    const blankTh = document.createElement('th');
    blankTh.textContent = "";
    headerRow.appendChild(blankTh);

    // Adjust labels as needed:
    const pickLabels = ["NW1","NW2","NW3","AW1","AW2","AW3","ND1","ND2","AD1","AD2","NFC","AFC","SB"];
    pickLabels.forEach(lbl => {
        const th = document.createElement('th');
        th.textContent = lbl;
        headerRow.appendChild(th);
    });
    table.appendChild(headerRow);

    picksData.forEach(item => {
        const [name, picks] = item;
        const row = document.createElement('tr');

        const nameTd = document.createElement('td');
        nameTd.textContent = name;
        row.appendChild(nameTd);

        picks.forEach(p => {
            const td = document.createElement('td');
            td.textContent = p;
            row.appendChild(td);
        });

        table.appendChild(row);
    });
}

// Helper: compute left(i), right(i), or parent(i)
function left(i) { return 2*i; }
function right(i) { return 2*i + 1; }
function parent(i) {
    return (i % 2 === 0) ? i/2 : (i-1)/2;
}

// Right tooltip (same as your old code)
function rightTooltip(i, bigDic) {
    let s = "<table>";
    s += "<tr>";
    s += "<th>Name</th><th>Total</th>";
    if (parseInt(i) < Math.pow(2, 12)) {
        s += "<th>Left</th><th>Right</th>";
    }
    s += "</tr>";

    const probs = bigDic["right"][i];
    if (parseInt(i) < Math.pow(2, 12)) {
        const l = left(parseInt(i)).toString();
        const r = right(parseInt(i)).toString();
        const probsL = bigDic["right"][l];
        const probsR = bigDic["right"][r];
        // Sort descending
        const combined = probs.map((val, idx) => [idx, val]);
        combined.sort((a,b) => b[1] - a[1]);

        combined.forEach(([teamIdx, val]) => {
            const pct = Math.round(val * 100) + "%";
            const pctL = Math.round(probsL[teamIdx] * 100) + "%";
            const pctR = Math.round(probsR[teamIdx] * 100) + "%";
            s += `<tr><td>${bigDic["names"][teamIdx]}</td><td>${pct}</td><td>${pctL}</td><td>${pctR}</td></tr>`;
        });
    } else {
        const combined = probs.map((val, idx) => [idx, val]);
        combined.sort((a,b) => b[1] - a[1]);
        combined.forEach(([teamIdx, val]) => {
            s += `<tr><td>${bigDic["names"][teamIdx]}</td><td>${Math.round(val*100)}%</td></tr>`;
        });
    }
    s += "</table>";
    return s;
}

// Left tooltip
function leftTooltip(i, bigDic) {
    const prob = Math.round(bigDic["left"][i] * 100);
    const teams = bigDic["main"][i];
    return `${teams[0]}: ${prob}%  <br /> ${teams[1]}: ${100 - prob}%`;
}

// If i >= 2^13 => leaf node => scoreboard
function winText(i, bigDic) {
    const offset = Math.pow(2, 13) - 1;
    const idx = i - offset;
    const scores = bigDic["scores"][idx];
    const combined = scores.map((val, i) => [i, val]);
    combined.sort((a,b) => b[1] - a[1]);
    let s = "";
    combined.forEach(([teamIdx, val]) => {
        s += `${bigDic["names"][teamIdx]}: ${val} <br />`;
    });
    return s;
}

// LAZY BUILDER: expand or create child nodes on-demand
function expandNode(i, bigDic, parentUl) {
    // If a <li> for node i already exists, do nothing
    if (document.getElementById(i.toString())) return;

    const li = document.createElement('li');
    li.id = i.toString();

    // If the game is decided, show the winner & no children
    const decided = bigDic["decided"][i];
    if (decided !== undefined) {
        // decided means we have an integer representing the winner's index
        li.classList.remove('hide');
        const a = document.createElement('a');
        const winnerName = bigDic["names"][decided];

        a.innerHTML = `<b>Decided:</b> ${winnerName}`;
        li.appendChild(a);
        parentUl.appendChild(li);
        return;
    }

    // If i >= 2^13 => leaf => show final scoreboard
    if (parseInt(i) >= Math.pow(2, 13)) {
        // final scoreboard
        li.classList.remove('hide');
        const a = document.createElement('a');
        a.innerHTML = winText(parseInt(i), bigDic);
        li.appendChild(a);
        parentUl.appendChild(li);
        return;
    }

    // If not decided and not a leaf => normal node
    // starts hidden except for i=1
    if (i === 1) {
        li.classList.remove('hide');
    } else {
        li.classList.add('hide');
    }

    const teams = bigDic["main"][i];
    const a = document.createElement('a');
    a.classList.add('tooltip');

    // Setup left B
    const leftB = document.createElement('b');
    leftB.textContent = teams[0];
    leftB.id = i.toString() + "L";
    leftB.onclick = () => {
        // Expand the left child if not decided
        expandChild(left(i), bigDic, subUl);
        cC(left(i).toString(), leftB.id);
    };

    // Setup right B
    const rightB = document.createElement('b');
    rightB.textContent = teams[1];
    rightB.id = i.toString() + "R";
    rightB.onclick = () => {
        expandChild(right(i), bigDic, subUl);
        cC(right(i).toString(), rightB.id);
    };

    // Right tooltip
    const spanRight = document.createElement('span');
    spanRight.classList.add('righttt');
    spanRight.innerHTML = rightTooltip(i.toString(), bigDic);

    // Left tooltip
    const spanLeft = document.createElement('span');
    spanLeft.classList.add('lefttt');
    spanLeft.innerHTML = leftTooltip(i.toString(), bigDic);

    a.appendChild(leftB);
    a.appendChild(document.createTextNode(" v "));
    a.appendChild(rightB);
    a.appendChild(spanRight);
    a.appendChild(spanLeft);

    li.appendChild(a);

    // Child <ul> for the sub-nodes, created lazily
    const subUl = document.createElement('ul');
    li.appendChild(subUl);

    parentUl.appendChild(li);
}

// Expand a single child
function expandChild(childId, bigDic, parentUl) {
    // Only build it if it doesn't exist
    if (!document.getElementById(childId.toString())) {
        expandNode(childId, bigDic, parentUl);
    }
}

// Build the top-level bracket
function buildBracket(bigDic) {
    const bracketRoot = document.getElementById('bracket-root');
    const outerUl = document.createElement('ul');
    bracketRoot.appendChild(outerUl);

    // Build only the top node (i=1) initially
    expandNode(1, bigDic, outerUl);
}

// On page load
window.addEventListener('DOMContentLoaded', () => {
    fetch('big_dic.json')
    .then(resp => resp.json())
    .then(bigDic => {
        // Build picks
        buildPicksTable(bigDic["picks"]);
        // Build bracket lazily
        buildBracket(bigDic);

        // If you want to auto-click decided games, etc.
        click_played_games();
    })
    .catch(err => console.error(err));
});
