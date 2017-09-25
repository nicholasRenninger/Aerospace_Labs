function plottruss(xyz,topo,eforce,fbc,rads,pltflags)
%function plottruss(xyz,topo,eforce,fbc,rads,pltflags)
%----------------------------------------------------
%
%  plot 3-truss, bars colored accoring to force
%  supported nodes are plotted in red
%  non-supported nodes are plotted in black
%
%  Input:   xyz -  x,y,and z coordinates of nodes 
%                  ( number of nodes x 3 )
% 
%                    Node 1 - [ x1 y1 z1;
%                    Node 2 -   x2 y2 z2;
%                      ...        ...
%                    Node n -   xn yn zn ];
%
%           topo -  topology of truss
%                   ( number of bars x 2 )
% 
%                    Member 1 - [ NodeA NodeB;
%                    Member 2 -   NodeD NodeC;
%                      ...           ...
%                    Member m -   NodeX NodeK ];
%
%           eforce - internal bar forces
%                    ( number of bars x 1 )
%
%                    Member 1 - [ InternalForce1;
%                    Member 2 -   InternalForce2;
%                      ...           ...
%                    Member m -   InternalForceM ];
%
%           fbc -    id numbers of nodes which are supported
%                    ( number of supported nodes x 1 )
%
%           rads -   plot radius of bars and joints
%                        1 x 1 : automatic ratio (Recommend: 0.01)
%                        3 x 1 : [ bar, node, suported node]
%
%           pltflags - flags for printing annotation
%                      (3 x 1)
%                      1. component: 0/1 - plot node id numbers
%                      2. component: 0/1 - plot bar id numbers
%                      3. component: 0/1 - plot force value
%                      4. component: 0/1 - 2D(0) or 3D(1) view 
%
%--------------------------------------------------------
% Kurt Maute for ASEN 2001 Oct. 2006
%   Revised Oct. 2007 by Sungeun Jeon
%   Revised Sep. 2010 by Kurt Maute
%--------------------------------------------------------

figure(1);
clf;

% check input

if nargin < 6; error('routine requires 6 input parameters'); end

% extract

[numnode, dim]=size(xyz);
numelem = size(topo,1);

if dim ~= 3
   display('Error in plottruss: 3 coordinates are needed for array xyz');
   return;
end

% extract min and max force values

minfrc=floor(min(eforce));
maxfrc=ceil(max(eforce));

% define radius of bars

if length(rads) == 1
    radb = rads(1);
    radj = 1.75*radb;
    radk = 1.5*radj;
else
    radb = rads(1);
    radj = rads(2);
    radk = rads(3);
end

% plot bars

figure(1)

for i=1:numelem
    na=topo(i,1);
    nb=topo(i,2);
    [xc,yc,zc]=plotbar(xyz(na,:),xyz(nb,:),radb);
    cc=eforce(i)*ones(size(xc));
    surf(xc,yc,zc,cc,'EdgeColor','none');
    if pltflags(2) > 0
        text((xyz(na,1)+xyz(nb,1))/2+1.8*radb,(xyz(na,2)+xyz(nb,2))/2+1.8*radb,(xyz(na,3)+xyz(nb,3))/2+1.8*radb,num2str(i));
    end
    if pltflags(3) > 0
        text((xyz(na,1)+xyz(nb,1))/2+1.8*radb,(xyz(na,2)+xyz(nb,2))/2+1.8*radb,(xyz(na,3)+xyz(nb,3))/2+1.8*radb,sprintf('%.2f',eforce(i)));
    end
    hold on;
end

% plot node id numbers

if pltflags(1) > 0
    for i=1:numnode
            text(xyz(i,1)+1.8*radj,xyz(i,2)+1.5*radj,xyz(i,3)+1.3*radj,num2str(i));
    end
end
    
colorbar;
caxis([minfrc maxfrc])

% plot ball joints

for i=1:numnode
    [sx,sy,sz]=plotnode(xyz(i,:),radj);
    surf(sx,sy,sz,'EdgeColor','none','FaceColor','black');
    hold on;
end

% plot supported nodes

for i=1:length(fbc)
    na=fbc(i);
    [sx,sy,sz]=plotnode(xyz(na,:),radk);
    surf(sx,sy,sz,'EdgeColor','none','FaceColor','red');
    hold on;
end

% plot parameters

axis('equal');
title('Member forces');

lightangle(-45,30)
set(gcf,'Renderer','openGl')
set(findobj(gca,'type','surface'),...
    'FaceLighting','phong',...
    'AmbientStrength',.3,'DiffuseStrength',.8,...
    'SpecularStrength',.9,'SpecularExponent',25,...
    'BackFaceLighting','unlit')

if pltflags(4) 
    % use default
else
    % set view point to 0,0,1
    view([0 0 1]);    
end

return

function [sx,sy,sz]=plotnode(xyz,rads)
%--------------------------------------------------------
% returns sphere of radius rads at position xyz (3x1)
%--------------------------------------------------------
% Kurt Maute for ASEN 2001 Oct. 2006
%--------------------------------------------------------
[sx,sy,sz]=sphere(30);
nl=length(sx);
omat=ones(size(sx));
sx=rads*sx+xyz(1)*omat;
sy=rads*sy+xyz(2)*omat;
sz=rads*sz+xyz(3)*omat;

return

function [xc,yc,zc]=plotbar(xa,xb,rads)
%--------------------------------------------------------
% returns cylinder of radius rads
% endpoints defined by xa (3x1) and xb (3x1)
%--------------------------------------------------------
% Kurt Maute for ASEN 2001 Oct. 2006
%--------------------------------------------------------

xba=xb-xa;
len=norm(xba);

% create basic cylinder

[xc,yc,zc]=cylinder([rads rads],20);

% stretch cylinder

cmat=[len*zc' xc' yc']; 

% create transformation matrix

ev1=1/len*xba';
eva=[ev1(2); -ev1(1); 0];

if (norm(eva) == 0)
    eva=[ev1(3); 0;  -ev1(1)];
    if (norm(eva) == 0)
      eva=[0; ev1(3); -ev1(2)];
    end
end

eva=1/norm(eva)*eva;
ev2=cross(ev1,eva);
ev3=cross(ev1,ev2);

T=[ev1 ev2 ev3];

% rotate cylinder

cpmat(:,[1 3 5])=(T*cmat(:,[1 3 5])')';
cpmat(:,[2 4 6])=(T*cmat(:,[2 4 6])')';

nl=length(xc);
omat=ones(nl,1);

xc(1,:)=cpmat(:,1)+xa(1)*omat;
xc(2,:)=cpmat(:,2)+xa(1)*omat;
yc(1,:)=cpmat(:,3)+xa(2)*omat;
yc(2,:)=cpmat(:,4)+xa(2)*omat;
zc(1,:)=cpmat(:,5)+xa(3)*omat;  
zc(2,:)=cpmat(:,6)+xa(3)*omat;  

return
