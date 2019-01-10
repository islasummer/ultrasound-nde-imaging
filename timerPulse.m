% Trigger pulse for the 555 monostable timer
writeDigitalPin(a, 'D8', 0);
pause(0.001); % Wait for 1ms
writeDigitalPin(a, 'D8', 1);