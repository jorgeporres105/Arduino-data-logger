%% Conexión al Arduino
a = arduino('COM8', 'Uno', 'Libraries', {'rotaryEncoder'});

% Pines (ajusta si usaste otros)
pwmPin  = 'D9';   % ENA del L298N (PWM)
in1Pin  = 'D8';   % IN1
in2Pin  = 'D7';   % IN2
encPinA = 'D2';   % C1 encoder
encPinB = 'D3';   % C2 encoder

% Configurar dirección fija del motor (por ahora solo en un sentido)
writeDigitalPin(a, in1Pin, 1);
writeDigitalPin(a, in2Pin, 0);

% Pulsos por revolución del encoder (elige un valor razonable)
PPR = 20;   % PROVISIONAL: luego lo puedes ajustar

% Crear objeto encoder con PulsesPerRevolution
enc = rotaryEncoder(a, encPinA, encPinB, 200);

% Resetear el contador
resetCount(enc);

%% Parámetros de muestreo
Ts      = 0.01;     % 10 ms
T_total = 10;       % 10 s
N       = T_total / Ts;

% Prealocar vectores
t      = (0:N-1)' * Ts;   % tiempo
u      = zeros(N,1);      % entrada (0 o 5)
y_vel  = zeros(N,1);      % salida (velocidad en rev/s aprox.)

%% Bucle de muestreo
for k = 1:N
    
    % Entrada (escalón a los 2 s)
    if t(k) < 2
        u(k) = 0;
    else
        u(k) = 5;
    end
    
    % Traducir u (0 o 5) → duty cycle (0–0.5)
    duty = (u(k) / 5) * 0.5;
    writePWMDutyCycle(a, pwmPin, duty);

    % Leer velocidad del encoder (en rev/s usando PPR)
    y_vel(k) = readSpeed(enc);

    pause(Ts);   % Esperar siguiente instante de muestreo
end

% Apagar motor
writePWMDutyCycle(a, pwmPin, 0);

%% Ahora tienes t, u, y_vel en el workspace
disp("Datos completados. Para identificación puedes usar:");
disp("data_vel = iddata(y_vel, u, Ts);");
