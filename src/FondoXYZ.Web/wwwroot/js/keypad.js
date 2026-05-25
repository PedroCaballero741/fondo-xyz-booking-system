(function () {
    var pin = "";
    var order = [];

    function shuffle(arr) {
        for (var i = arr.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
        }
        return arr;
    }

    function renderKeypad() {
        order = shuffle([0,1,2,3,4,5,6,7,8,9]);
        var kp = document.getElementById("keypad");
        if (!kp) return;
        kp.innerHTML = "";
        order.forEach(function(digit) {
            var btn = document.createElement("button");
            btn.type = "button";
            btn.textContent = digit;
            btn.onclick = function() { appendDigit(digit); };
            kp.appendChild(btn);
        });
        // Clear button
        var clear = document.createElement("button");
        clear.type = "button";
        clear.textContent = "Limpiar";
        clear.className = "keypad-clear";
        clear.onclick = clearPin;
        kp.appendChild(clear);
    }

    function appendDigit(d) {
        if (pin.length >= 4) return;
        pin += d;
        updateDisplay();
    }

    function clearPin() {
        pin = "";
        updateDisplay();
    }

    function updateDisplay() {
        var disp = document.getElementById("pin-display");
        if (disp) disp.value = "\u25CF".repeat(pin.length);
        var hidden = document.getElementById("Clave");
        if (hidden) hidden.value = pin;
    }

    document.addEventListener("DOMContentLoaded", function() {
        renderKeypad();
        var shuffleBtn = document.getElementById("keypad-shuffle");
        if (shuffleBtn) shuffleBtn.onclick = function() { clearPin(); renderKeypad(); };
    });
})();
