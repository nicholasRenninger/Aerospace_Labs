%%

clear all;
close all ;
clc;

%Read data and initialize vectors
data = xlsread('TestData.xlsx');
F = data(:,2);
a = data(:,3);
w = data(:,4);
d_f = data(:,5);

tot_length = .9144; %meters
height = .0206375; %meters
heightfoam = 0.01905; %m
heightbalsa = 0.0015875/2; %meters
distancebalsacentroid = 0.009921875; %m distance from balsa centroid to centroid of wing
c = 0.01031875; %meters
L = .8382; % meters
FOS = 1.7;

set(0,'defaulttextinterpreter','latex')

%define Youngs Modulus and Densities
E_balsa = 3.2954*10^9; %Pa
E_foam = 0.035483*10^9;

densitybalsa = 130; %kg/m^3
densityfoam = 20.824;


%%
x = linspace(0,0.4191,1000);
sz = size(a);

for i = 1:sz(1)
    for j = 1:1000

if x(j)<=a(i)
Moment(i,j) = (x(j)-.0381).*(F(i))/2;
Shear(i,j) = F(i)/2;
else
 Moment(i,j) = (x(j)-.0381).*(F(i))/2-(x(j)-a(i)).*F(i)/2;
 Shear(i,j) = 0;
end
    end
Momentbeam = [Moment(i,:),flip(Moment(i,:))];
TotMoment(i,:) = Momentbeam;
TotShear(i,:) = [Shear(i,:),-flip(Shear(i,:))];
end
x = linspace(0,0.8382,2000);


%%
for i = 1:sz(1)
    I_f(i) = (1/12)*(heightfoam)^3*w(i);
    parallel = heightbalsa*w(i)*(distancebalsacentroid)^2;
    I_b(i) = 2*(w(i)*((heightbalsa)^3)/12+parallel);
    
    for j = 1:2000
        FlexureStress(i,j) = -TotMoment(i,j)*c/(I_b(i)+(E_foam/E_balsa)*I_f(i));
        ShearStress(i,j) = (3/2)*TotShear(i,j)/(heightfoam*w(i));

    end
end


%%
for i = 1:sz(1)
    maxes(i) = find(x >= d_f(i),1);
    MAXTENSILE(i) = abs(ShearStress(i,maxes(i)));
    MAXFLEX(i) = abs(FlexureStress(i,maxes(i))); 
end
meanflex = mean(MAXFLEX);
stdflex = std(MAXFLEX);

vec = 0;
count = 0;
for i = 1:sz(1)
    if MAXFLEX(i)>stdflex+meanflex
        vec = [vec,i];
    elseif MAXFLEX(i)<meanflex-stdflex
        vec = [vec,i];
    end
    if MAXTENSILE(i) == 0
        count = [count,i];
    end
end
vec(1) = [];
MAXFLEX(vec) = [];
count(1) = [];
MAXTENSILE(count) = [];
flex_stress_fail = mean(MAXFLEX);
fprintf(['The average flexure stress at failure for the'...
    'wing material is: %0.3e Pa\n'], flex_stress_fail)

numFlexFails = length(MAXFLEX);
flex_stress_fail_line = ones(1, numFlexFails) * flex_stress_fail;

hFig = figure(1);
set(hFig, 'Position', [100 100 1600 900])
hold on 

plot(flex_stress_fail_line, ':', 'LineWidth', 3)
plot(MAXFLEX, 'rs', 'MarkerFaceColor', [0.5, 0.5, 0.5], ...
        'MarkerSize', 15, 'LineWidth', 3)
    
xlim([1, inf])
title('Moment Failure Stresses')
xlabel('Test Trial')
ylabel('$\sigma_{fail}$ (Pa)')
leg = legend(sprintf('Filtered, Avg. $\\sigma_{fail} = %0.3e$ Pa',...
    flex_stress_fail), '$\sigma_{fail}$ during each test each test',...
    'location', 'best');
set(leg,'Interpreter','latex')
set(gca,'FontSize', 28)

hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meantensile = mean(MAXTENSILE);
stdtensile = std(MAXTENSILE);

vec = 0;
len = size(MAXTENSILE);
for i = 1:len(1)
    if MAXTENSILE(i)>stdtensile+meantensile
        vec = [vec,i];
    elseif MAXTENSILE(i)<meantensile-stdtensile
        vec = [vec,i];
    end
end
vec(1) = [];
MAXTENSILE(vec) = [];
tensile_stress_final = mean(MAXTENSILE);
fprintf(['The average shear stress at failure for the'...
    'wing material is: %0.3e Pa\n'], tensile_stress_final)

numTensFails = length(MAXFLEX);
tensile_stress_final_line = ones(1, numTensFails) * tensile_stress_final;

hFig = figure(2);
set(hFig, 'Position', [100 100 1600 900])
hold on 

plot(tensile_stress_final_line, ':', 'LineWidth', 3)
plot(MAXTENSILE, 'bs', 'MarkerFaceColor', [0.5, 0.5, 0.5], ...
        'MarkerSize', 15, 'LineWidth', 3)

xlim([1, 6])
title('Shear Failure Stresses')
xlabel('Test Trial')
ylabel('$\tau_{fail}$ (Pa)')
leg = legend(sprintf('Filtered, Avg. $\\tau_{fail} = %0.3e$ Pa',...
    tensile_stress_final), '$\tau_{fail}$ during each test each test',...
    'location', 'best');
set(leg,'Interpreter','latex')
set(gca,'FontSize', 28)


%%
syms x width p0

q = p0 * sqrt(1-(2*x/L)^2) * width;
reactionforce = int(q,-.4191,.4191)/2;
ShearWing = int(q, x);
MomentWing = int(ShearWing, x);
NewMoment = MomentWing;

x = 0.4191;
adjustment = subs(MomentWing);
MomentWing = MomentWing - adjustment;


flexurestresspoint = -1 * MomentWing .* c ./ (1.5886*10^-8 + ...
                      (mean(E_foam)/mean(E_balsa)) * 5.8533*10^-8);

x = 0;
width = 4*.0254;
flexurestresspoint = subs(flexurestresspoint);
p_naught = double(solve(flex_stress_fail == flexurestresspoint,p0));
p0 = p_naught;
fprintf('FOS: %0.2f\n', FOS)
fprintf('P_o (w/out FOS) = %0.3e Pa\n', p0)
fprintf('P_o (w/ FOS) = %0.3e Pa\n', p0/FOS)
p0 = p0 / FOS;

syms x
q = width * p0 * sqrt(1-(2*x/L)^2);
load = subs(int(q,x,[-L/2 L/2]));
fprintf('The maximum the wing will support is %0.3g N.\n', double(load*4))
distance = linspace(-.4191,.4191, 100);
load = load./distance;



syms x 
q = width * p0 * sqrt(1-(2*x/L)^2);
shear = int(q,x);
moment = -int(shear,x);
x = L/2;
correction = subs(moment);
moment = moment-correction;
fprintf('The moment equation is: \n')
display(moment)

hFig = figure(3);
set(hFig, 'Position', [100 100 1600 900])
hold on 

x = distance;
shearreal = abs(subs(shear));
shearreal = abs(shearreal);
momentreal = subs(moment);
plot(distance, abs(subs(moment)), 'r', 'LineWidth', 3)
plot(distance, shearreal,'b', 'LineWidth', 3)

title('Shear and Bending Stresses as Functions of $x$')
xlabel('$x$ (m)')
ylabel({'Moment $(N\>m)$'; 'Force $(N)$'})
leg = legend('$M(x)$', '$V(x)$', 'location', 'best');
set(leg,'Interpreter','latex')
xlim([min(distance), max(distance)])
set(gca,'FontSize', 28)

syms width x 
q = width * p0 * sqrt(1-(2*x/L)^2);
v = int(q,x);
m = -int(v,x)- correction;

syms f
momentallow = solve(-1 * f .* c ./ (1.5886*10^-8 + ...
    (mean(E_foam)/mean(E_balsa)) * 5.8533*10^-8) == flex_stress_fail,f);
momentallow = double(momentallow);
syms width x

for i = 1:100
    x = distance(i);
    w1 = solve(momentallow == subs(m),width);
    %w1 = solve(flex_stress_fail == subs(m),width);
    if abs(x) == L/2
    w2 = 0;
    else
    w2 = solve(-momentallow == subs(q), width);
    % w2 = solve(tensile_stress_final/-40 == subs(q), width);
    %w2 = solve(tensile_stress_final == subs(v), width);
    end
    wideness(i) = w1+w2;
end

wideness(1) = [];
wideness(end) = [];
distance(1) = [];
distance(end) = [];

w = double(wideness) / 0.0254;
w = abs(w);
w = w * (2/(max(w)));

hFig = figure(4);
set(hFig, 'Position', [100 100 1600 900])
hold on 
area(distance, w, 'FaceColor', [0.9, 0.75, 0.5])
area(distance, -w, 'FaceColor', [0.9, 0.75, 0.5])
plot(distance, w, 'b', distance, -w, 'b', 'LineWidth', 3)
title('Wing Profile as a Function of $x$')
xlabel('$x$ (m)')
ylabel('$w(x)$ (in)')
xlim([min(distance), max(distance)])
set(gca,'FontSize', 28)
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
syms x  
q = 4*.0254 * p_naught * sqrt(1-(2*x/L)^2);

vector = [-.4191, -.3143, -.2095,-.1048,0,.1048,.2095,.3143,.4191];
for i = 1:8
    force(i) = double(int(q,[vector(i),vector(i+1)]));
    centroid(i) = double(int(q*x,[vector(i),vector(i+1)]))/force(i);
end
syms tot_length
x1 = double(solve(((centroid(2)-centroid(1))-tot_length)*(force(1)+((.1968+(2*.0628))*9.81*.5)) == (force(2)+((.1968+(2*.0628))*9.81*.5))*tot_length))
x2 = double(solve(((centroid(4)-centroid(3))-tot_length)*force(3) == tot_length * force(4)))
x3 = double(solve((((x1-centroid(2))-(x2-centroid(4)))-tot_length)*((force(1)+((.1968+(2*.0628))*9.81*.5))+(force(2)+((.1968+(2*.0628))*9.81*.5)))  == (force(3)+force(4))*tot_length))
