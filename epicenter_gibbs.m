% Penentuan Epicenter
% Gibbs Sampler

clear, clc, close all

%Penentuan Ruang Model
xmin=0;
xmax=200;
ymin=0;
ymax=200;
x=linspace(xmin,xmax,60);
y=linspace(ymin,ymax,60);

% posisi episenter sebenarnya
x0=105;
y0=80;

% posisi stasiun gempa
xsts=[20;15;160;170];
ysts=[25;155;150;20];

% cepat rambat gelombang
vp=5;

% Forward Modelling
tobs=1/vp*sqrt((xsts-x0).^2+(ysts-y0).^2);

% Pemilihan model awal secara random uniform
x1 = rand*(xmax-xmin);
y1 = rand*(ymax-ymin);
xaw=x1;
yaw=y1;
%=======================================================================
%Jumlah iterasi
niter=1000;

%Proses Iterasi
for iter =1:niter
    % Pencarian model perturbasi pada arah x dengan y fixed
    temp_x = 0;
    for xdir =1:length(x)
        tcal1=1/vp*sqrt((xsts-x(xdir)).^2+(ysts-y1).^2); % tcal1 = Tcal pada arah x
        Es_x = mean(sqrt((tcal1-tobs).^2));
        xprob= exp(-Es_x);
        temp_x = temp_x +xprob;
        Ps_x(xdir) = temp_x;
    end
    % Membuat probabilitas menjadi jumlahnya sama dengan 1
    Pk_x=(Ps_x-min(Ps_x))/(max(Ps_x)-min(Ps_x));
    
    u = rand;
    for xdir = 1:length(Pk_x)
        % Pemilihan model baru terhadap bilangan R[0,1] 
        if u<Pk_x(xdir)
            x1 = x(xdir);
                 break
        end
    end
    x_new(iter) = x1;
    %=======================================================================
    % Pencarian model perturbasi pada arah y dengan x baru fixed 
    temp_y = 0;
    for ydir =1:length(y)
        tcal2=1/vp*sqrt((xsts-x1).^2+(ysts-y(ydir)).^2); % tcal2 = Tcal pada arah y
        Es_y = mean(sqrt((tcal2-tobs).^2));
        yprob= exp(-Es_y);
        temp_y = temp_y +yprob;
        Ps_y(ydir) = temp_y;
    end
    % Membuat probabilitas menjadi jumlahnya sama dengan 1
    Pk_y=(Ps_y-min(Ps_y))/(max(Ps_y)-min(Ps_y));
    
    u = rand;
    for ydir = 1:length(Ps_y)
        % Pemilihan model baru terhadap bilangan R[0,1] 
        if u < Pk_y(ydir)
            y1 = y(ydir);
            break
        end
    end
    y_new(iter) = y1;

end
%=======================================================================
%% Visualisasi;
fh=figure(1);
plot(x_new,y_new,'s','color','c','MarkerSize',5,'MarkerFaceColor','#000000')
hold on
plot(x0,y0,'*r','Linewidth',2,'MarkerSize',10)
plot(xsts,ysts,'v','MarkerSize',8,'MarkerFaceColor','k','MarkerEdgeColor','r')
plot(xaw,yaw,'s','color','k','MarkerSize',8,'MarkerFaceColor','#0000FF')
plot(x_new(end),y_new(end),'s','color','k','MarkerSize',8,'MarkerFaceColor','#FF0000')
title('Determination of Earthquake Epicenter using Gibbs Sampling Algorithm')
ylabel('y-location')
xlabel('x-location')
legend ('Update Model','True Epicenter','Station','Initial Model','Final Model')
axis equal
axis([0 xmax 0 ymax])

fh.WindowState='maximize';
print('-dpng','Epicenter Gibbs Sampler','-r500');