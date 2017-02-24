function [ret_parameter] = channelEstimation(csi_sample)
%% csi_sample: M*1 complex
% theta is a L*3 vector: [alpha, phi, tau] 
% [alpha, -, -]_l: the amplitude of the path l;
% [-, phi, -]_l: the azimuth angle of the path l;
% [-, -, tau]_l: the delay of the path l;
if nargin <= 0
    csi_sample = [0.5+0.1j; 0.4+0.2j; 0.3+0.3j];
end


globals_init();

global ITERATION L

% parameters: ITERATION+1 cell, inside each cell is a struct 
% (alpha, phi, tau)
parameters = cell(ITERATION+1, 1);
for i = 1:ITERATION+1
    parameters{i} = struct('alpha', zeros(1, L), ...
    'phi', zeros(1, L), 'tau', zeros(1, L));
end

parameters{1} = init(csi_sample, parameters{1});


%% Iterating;
for i = 1:ITERATION
    
    % Expectation step (E-step)
    X = eStep(parameters{i}, csi_sample);
    
    % Maximization step (M-step)
    parameters{i+1}.tau = opt_tau(parameters{i}.phi, X);
    parameters{i+1}.phi = opt_phi(parameters{i+1}.tau);
    parameters{i+1}.alpha = compute_alpha(parameters{i+1}.tau,... 
        parameters{i+1}.phi, X);
end

ret_parameter = parameters{ITERATION+1};
end

function ret = opt_tau(phi, X)
start_phi = 0; end_phi = pi; step_phi = pi/10;  % unit: radius
n_phi = (end_phi - start_phi) / step_phi + 1;

phi_space = zeros(n_phi, L);
for i = 1:n_phi
    phi_space(i,:) = compute_Z(parameter.tau,... 
        zeros(1, L)+step_phi*(i-1)+start_phi, X);
end
[~, I] = max(abs(phi_space));
parameter.phi = step_phi*(I-1)+start_phi;



end





function globals_init
    %% physical
    % labmda: wavelength of the signal;
    % freq: frequency of the signal;
    % M: antenna array size;
    % L is the number of propagation paths;
    % D is spacing between adjacent antennas of the receiver antenna array;
    % N: # of sample
    global FREQUENCY SPEED_OF_LIGHT LAMBDA M L D ITERATION N DOMAIN_TAU ...
        DOMAIN_PHI DOMAIN_ALPHA
    FREQUENCY = 5.2e9;  %unit hz
    SPEED_OF_LIGHT = 3e8;  %unit m/s
    LAMBDA = SPEED_OF_LIGHT/FREQUENCY;
    M = 3;
    L = 8;
    D = 12;
    ITERATION = 999;
    N = 1;
    DOMAIN_TAU = struct('start', 10, 'end', 30, 'step', 1); % unit: ns
    DOMATN_TAU.length = (DOMAIN_TAU.end - DOMAIN_TAU.start) ...
        / DOMAIN_TAU.step + 1;
    
    DOMAIN_PHI = struct('start', 0, 'end', pi, 'step', pi/10); % unit: radius
    DOMATN_PHI.length = (DOMAIN_PHI.end - DOMAIN_PHI.start) ...
        / DOMAIN_PHI.step + 1;
    
    
    
    
    
end