// CONFIG
const use_12h_clock = false;
const default_user = 0;

// local variables
let selected_user = "";
let valid_image = /.*\.(png|svg|jpg|jpeg|bmp)$/i;

///////////////////////////////////////////////
// CALLBACK API. Called by the webkit greeeter
// Docs: https://web.archive.org/web/20190522095438/https://doclets.io/Antergos/lightdm-webkit2-greeter/master
///////////////////////////////////////////////

// Called when the greeter asks to show a login prompt for a user
function show_prompt(text) {
    let password_container = document.getElementById("password_container");
    let password_entry = document.getElementById("password_entry");

    if (!isVisible(password_container)) {
        let users = document.getElementsByClassName("user");
        let user_node = document.getElementById(selected_user);
        let rect = user_node.getClientRects()[0];
        let parentRect = user_node.parentElement.getClientRects()[0];
        let center = parentRect.width/2;
        let left = center - rect.width/2 - rect.left;
        if (left < 5 && left > -5) {
            left = 0;
        }
        for (let i = 0; i < users.length; i++) {
            let node = users[i];
            setVisible(node, node.id === selected_user);
            node.style.left = left;
        }

        setVisible(password_container, true);
        password_entry.placeholder= text.replace(":", "");
    }
    password_entry.value = "";
    password_entry.focus();
}

// Called when the greeter asks to show a message
function show_message(text) {
    let content = document.getElementById("message_content");
    content.innerHTML = text;
    content.classList.remove("error");

    let message = document.getElementById("message");
    if (text) {
        message.classList.remove("hidden");
    } else {
        message.classList.add("hidden");
    }
}

// Called when the greeter asks to show an error
function show_error(text) {
    show_message(text);
    let message = document.getElementById("message_content");
    message.classList.add("error");
}

// Called when the greeter is finished with the authentication request
function authentication_complete() {
    let container = document.getElementById("session_container");
    let children = container.querySelectorAll("input");
    let key = "";
    for (let i = 0; i < children.length; i++) {
        let child = children[i];
        if (child.checked) {
            key = child.value;
            break;
        }
    }

    if (lightdm.is_authenticated) {
        if (key === "") {
            lightdm.login(lightdm.authentication_user, lightdm.default_session);
        } else {
            lightdm.login(lightdm.authentication_user, key);
        }
    } else {
        show_error("Authentication Failed");
        start_authentication(selected_user);
    }
}

// Called when the greeter wants us to perform a timed login
function timed_login(user) {
    lightdm.login (lightdm.timed_login_user);
}

//////////////////////////////
// Implementation
//////////////////////////////

document.addEventListener("keypress", e => {
    // document.getElementById('action_restart').innerText = "uwu";
    e.stopPropagation();
    if (selected_user !== null) {
        selected_user = null;
        lightdm.cancel_authentication();
        show_users();
    } else if (e.type === "click") {
        selected_user = e.currentTarget.id;
        start_authentication(selected_user);
    } else if (e.type === "keypress") {
	// Typing after booting will automatically select the first user and shell to input the
	// password.
        selected_user = document.getElementsByClassName("user_name")[default_user].parentElement.id;
        start_authentication(selected_user);
    }
});

function start_authentication(username) {
    lightdm.cancel_timed_login();
    selected_user = username;
    let userObj = lightdm.users.filter(user => (user.username) ? user.username === username : user.name === username)[0];
    if (typeof(userObj) !== "undefined" && userObj.session) {
        Array.prototype.slice.call(document.querySelectorAll("input[type=radio][name=session]"), 0).forEach(radio => {
            radio.checked = false;
            if (radio.value === userObj.session) radio.checked = true;
        });
    }
    else {
        Array.prototype.slice.call(document.querySelectorAll("input[type=radio][name=session]"), 0).forEach(radio => {
            radio.checked = false;
            if(radio.value === lightdm.default_session.key) radio.checked = true;
        });
    }
    lightdm.start_authentication(username);
}

function provide_secret() {
    show_message("Logging in...");
    entry = document.getElementById('password_entry');
    lightdm.respond(entry.value);
}

function show_users() {
    let users = document.getElementsByClassName("user");
    for (let i= 0; i < users.length; i++) {
        setVisible(users[i], true);
        users[i].style.left = 0;
    }
    setVisible(document.getElementById("password_container"), false);
    selected_user = null;
}

function setVisible(element, visible) {
    if (visible) {
        element.classList.remove("hidden");
    } else {
        element.classList.add("hidden");
    }
}

function isVisible(element) {
    return !element.classList.contains("hidden");
}

function update_time() {
    let time = document.getElementById("current_time");
    let date = new Date();
    let hh = date.getHours();
    let mm = date.getMinutes();
    let ss = date.getSeconds();
    if (use_12h_clock) {
        var suffix= "AM";
        if (hh > 12) {
            hh = hh - 12;
            suffix = "PM";
        }
    }
    if (hh < 10) { hh = "0"+hh; }
    if (mm < 10) { mm = "0"+mm; }
    if (ss < 10) { ss = "0"+ss; }
    time.innerHTML = use_12h_clock ? hh+":"+mm + " " + suffix : hh+":"+mm;
}

