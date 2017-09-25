%% Housekeeping
clear variables;
close all;
close hidden;
clc;

%% Initials
position={@(t)0,@(t)0,@(t)t};%try editing this for different s(t) functions
domain=[0,125];%change as needed as well
n=1000;
g=9.81;
syms t s

%% Solving for eq'ns
px=symfun(position{1}(t),t);
py=symfun(position{2}(t),t);
pz=symfun(position{3}(t),t);

vx=diff(px,t);
vy=diff(py,t);
vz=diff(pz,t);

ax=diff(vx,t);
ay=diff(vy,t);
az=diff(vz,t);

%% Integral Steps
speed=sqrt(2*g*(125-pz));
p=int(speed, 0, t); 
%lack of supression so the function may be analyzed
t_s=solve(s==p,t);
if isempty(t_s)
    error('That function be too crazy to solve for t(s)...');
end
t_s=t_s(1);

ax_s=symfun(ax(t_s),s);
ay_s=symfun(ay(t_s),s);
az_s=symfun(az(t_s),s);

a={matlabFunction(ax_s),matlabFunction(ay_s),matlabFunction(az_s)};

%% Graphing
f1=figure(1);
a1=axes('Parent',f1);
f2=figure(2);
a2=axes('Parent',f2);
pause(10)

red=@(t)(1-((t-domain(1))/(domain(2)-domain(1))));
green=@(t)(1-((2*abs(t-((domain(2)+domain(1))/2)))/abs(domain(2)-domain(1))));
blue=@(t)((t-domain(1))/(domain(2)-domain(1)));

%%{
for i=domain(1):((domain(2)-domain(1))/n):domain(2)
    
    plot3(position{1}(i),position{2}(i),position{3}(i),'.','Color',[red(i),green(i),blue(i)],'Parent',a1)
    hold on
    plot3(a{1}(i),a{2}(i),a{3}(i),'.','Color',[red(i),green(i),blue(i)],'Parent',a2)
    hold on
    drawnow;
    
end
%}
%%%%%%%%%%