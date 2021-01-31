"use strict";

let rotateStart = new THREE.Vector2(window.innerWidth/2, window.innerHeight/2);
let rotateEnd = new THREE.Vector2(0,0);
let rotateDelta = new THREE.Vector2(0,0);
let isDragging = false;
let MOUSE_SPEED_X = 0.5;
let MOUSE_SPEED_Y = 0.3;
let phi = 0;
let theta = 0;

window.addEventListener("mousedown", function(event) {
    rotateStart.set(event.clientX, event.clientY);
    isDragging = true;
});

window.addEventListener("mousemove", function(event) {
    if (!isDragging && !isPointerLocked()) {
        return;
    }

    if (isPointerLocked()) {
        let movementX = event.movementX || event.mozMovementX || 0;
        let movementY = event.movementY || event.mozMovementY || 0;
        rotateEnd.set(rotateStart.x - movementX, rotateStart.y - movementY);
    } else {
        rotateEnd.set(event.clientX, event.clientY);
    }

    rotateDelta.subVectors(rotateEnd, rotateStart);
    rotateStart.copy(rotateEnd);

    let element = document.body;
    phi += 2 * Math.PI * rotateDelta.y / element.clientHeight * MOUSE_SPEED_Y;
    theta += 2 * Math.PI * rotateDelta.x / element.clientWidth * MOUSE_SPEED_X;

    phi = Util.clamp(phi, -Math.PI/2, Math.PI/2);

    let euler = new THREE.Euler(-phi, -theta, 0, 'YXZ');
    camera.quaternion.setFromEuler(euler);
});

window.addEventListener("mouseup", function(event) {
    isDragging = false;
});

