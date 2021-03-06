% Chi^2 statistics for continuum agents with agg shocks
function[chi2sq] = gj_xi(hist_file, sim_file, sim_total, out_file)
%clear all;
if nargin<4 out_file = 'criterion.mat'; end;
%diary GJXiBenchKT2.log;
%diary GJXiHighVarKT2.log;
%diary GJXiHighMeanKT2.log
%disp('7--Benchmark')
    %disp('17--High Var')
    %disp('HC--High Mean')
    %disp('HM--Medium Mean')
%diary off;

% Analytical Moments--Unconditional--> Also change SimCond.mat below
load(hist_file); % Benchmark
load(sim_file);
%load HIST17;  % Higher Variance
%load HISTHC;  % Higher Mean 
%load HISTHM;  % Medium Mean

% parameters
if(ischar(sim_total)==1) sim_total = str2num(sim_total); end;

S=sim_total;
it=3;
T=21;
pt=T-it+1;
p=3*pt;

% analytical moments
agdpg=Allgrowk-1;
agdpgL=gro2level(agdpg);
afindpL=H;
afindp=(H(2:T)-H(1:T-1))./H(1:T-1);
athidxL=Theil;
athidx=(Theil(2:T)-Theil(1:T-1))./Theil(1:T-1);
az  = [agdpg(it-1:T-1) afindpL(it:T) athidxL(it:T)];
azs = ones(S,1)*az;

clear H Allgrowk Theil;

% MonteCarlo data
load(sim_file);
%load SimCond17;
%load SimHC;
%load SimHM;

xgdpg=Allgrowk-1;
xgdpgL=gro2level(xgdpg);
xfindpL=H;
xfindp=(H(:,2:T)-H(:,1:T-1))./H(:,1:T-1);
xthidxL=Theil;
xthidx=(Theil(:,2:T)-Theil(:,1:T-1))./Theil(:, 1:T-1);

% unconditional mean
ugdpgL=mean(xgdpgL);
ufindpL=mean(xfindpL);
uthidxL=mean(xthidxL);
ugdpg=mean(xgdpg);
ufindp=mean(xfindp);
uthidx=mean(xthidx);

xz  = [xgdpg(:,it-1:T-1) xfindpL(:,it:T) xthidxL(:,it:T)];
uz  = [ugdpg(it-1:T-1) ufindpL(it:T) uthidxL(it:T)]; % each macro variables
uzs = ones(S,1)*uz;

% Actual Data
%load thaidat2;
%load thaidat3k;
load thai_gro;
load thai_dat;


rgdpg=grinc'/100;
rgdpgL=gro2level(rgdpg);
rfindpL=part'/100;
rfindp=(rfindpL(2:T)-rfindpL(1:T-1))./rfindpL(1:T-1);
%rthidxL=TT_all_N'; % unadjusted Theil
rthidxL=TT_all_N+(uthidxL(1)-TT_all_N(1)); % adjusted
rthidx=(rthidxL(2:T)-rthidxL(1:T-1))./rthidxL(1:T-1);
rz  = [rgdpg(it-1:T-1) rfindpL(it:T) rthidxL(it:T)];
rzs = ones(S,1)*rz;

% Inverse of Var / NOTE: VAR is NOT divided by S or N!
% BUT sample average is not divided by N either so --> Need to Multiply
dxu = xz-uzs;
dxa = xz-azs;
dxr = xz-rzs;

tmvu= dxu'*dxu;
tmva= dxa'*dxa;
tmvr= dxr'*dxr;

imvu=inv(tmvu);
imva=inv(tmva);
imvr=inv(tmvr);

% Chi2 stats
xusq = diag(dxu*imvu*dxu');
xasq = diag(dxa*imva*dxa');
xrsq = diag(dxr*imvr*dxr');
xbsq = diag(dxr*imva*dxr');

% Actual Chi2

aru=rz-uz;
amsru=S*aru*imvu*aru';
ara=rz-az;
amsra=S*ara*imva*ara';  % Overall closeness using analytical mean

sxusq=diag(dxu*dxu');
samsru=aru*aru';
%break

% Decomposition of Chi2
azg=rz;
azg(1:pt)=az(1:pt);
azf=rz;
azf(pt+1:2*pt)=az(pt+1:2*pt);
azt=rz;
azt(2*pt+1:p)=az(2*pt+1:p);
azgf=az;
azgf(2*pt+1:p)=rz(2*pt+1:p);
azgt=az;
azgt(pt+1:2*pt)=rz(pt+1:2*pt);
azft=az;
azft(1:pt)=rz(1:pt);

arug=rz-azg;
aruf=rz-azf;
arut=rz-azt;
arugf=rz-azgf;
arugt=rz-azgt;
aruft=rz-azft;

amsrag=S*arug*imva*arug';  % growth only (19 data) metric 
amsraf=S*aruf*imva*aruf';  % fin only
amsrat=S*arut*imva*arut';  % Theil only
amsragf=S*arugf*imva*arugf'; % growth and fin (38)
amsragt=S*arugt*imva*arugt'; % growth and Theil
amsraft=S*aruft*imva*aruft'; % fin and Theil

pall=chi2cdf(amsra,p);
pg=chi2cdf(amsrag,pt);
pf=chi2cdf(amsraf,pt);
ph=chi2cdf(amsrat,pt);
pgf=chi2cdf(amsragf,2*pt);
pgt=chi2cdf(amsragt,2*pt);
pfh=chi2cdf(amsraft,2*pt);

decg=amsrag/amsra;
decf=amsraf/amsra;
dect=amsrat/amsra;
decgf=amsragf/amsra;
decgt=amsragt/amsra;
decft=amsraft/amsra;

%diary on
% Closeness metrics
%disp ('Confidence Region Chi2 values')
%disp('   Growth_only    FinDep_only    Ineq_only    Gro&Fin   Gro&Ineq   Fin&Ineq   Total')
%disp([amsrag amsraf amsrat amsragf amsragt amsraft amsra])
%disp('Associated probabilities in the same order')
%disp([pall pg pf ph pgf pgt pfh])
%disp('Note compare sum of two with combined values.')
%disp('If combined value is lower their correlation helps to reduce the distance from the mean.')

%disp('Relative Contribution')
%disp('   Growth   Fin.Dep. Inequality   Gr-Fin   Gr-Ineq    Fin-Ineq')
%disp([decg decf dect decgf decgt decft])
%diary off

% BEST PICK
%closeness=ncx2cdf(S*abs(xbsq),57,abs(amsra));
%[bestclose,bestloc]=min(closeness)
%bestvalchi=S*xasq(bestloc)
%chi2prob=chi2cdf(S*xasq(bestloc),57)

closeness=chi2cdf(S*xrsq,57);
%closeness=xbsq;
[bestclose,bestloc]=min(abs(closeness));
bestvalchi=S*xasq(bestloc);
chi2prob=chi2cdf(S*xasq(bestloc),57);

%diary on
%disp(' best fit chi2 prob   simulation number best fit to actual data')
%disp([bestclose  bestloc])
%disp(' chi2 value  chi2 prob around the expected path')
%disp([bestvalchi  chi2prob])
%diary off

% Plot data
xg=xgdpg;
xf=xfindpL;
xt=xthidxL;
ag=agdpg;
af=afindpL;
at=athidxL;
ug=ugdpg;
uf=ufindpL;
ut=uthidxL;
rg=rgdpg;
rf=rfindpL;
rt=rthidxL;
bg=xg(bestloc,:);
bf=xf(bestloc,:);
bt=xt(bestloc,:);

% Time Average
TA=T;
    %else
    %TA=T-1;
    %end

avethaig=mean(rg(1:T));
avethaif=mean(rf(1:T));
avethait=mean(rt(1:T));
aveexpg=mean(ug(1:T));
aveexpf=mean(uf(1:T));
aveexpt=mean(ut(1:T));
avebestg=mean(bg(1:T));
avebestf=mean(bf(1:T));
avebestt=mean(bt(1:T));

%diary on
%disp('Time Average of Variables')
%disp('  Income Fin.Dep. Inequality')
%disp([avethaig avethaif avethait;
 %aveexpg  aveexpf  aveexpt;
 %avebestg avebestf avebestt]*100)    
%disp(' Note that rows are in order of Actual Data, Expected Path, Best Pick')
%diary off

% Axis

t31=linspace(1976,2006,31);
t30=linspace(1976,2005,30);
t29=linspace(1976,2004,29);
t21=linspace(1976,1996,21);
t20=linspace(1977,1996,20);

TT=21;
tx=t21;
    
%figure%figAve
%subplot(3,1,1)
%plot(t20,ag(1:TT-1),'k',t20,ug(1:TT-1),'k-.',t20,rg(1:TT-1),'k--')
%legend('Expected Path','Ave. Simulation','Actual Data',2)
%title('GDP Growth')
%axis([1975,1997,0,0.15])

%subplot(3,1,2)
%plot(tx,af(1:TT),'k',tx,uf(1:TT),'k-.',tx,rf,'k--')
%title('Participation Rate')
%axis([1975,1997,0.05,0.3])    

%subplot(3,1,3)
%plot(tx,at(1:TT),'k',tx,ut(1:TT),'k-.',tx,rt,'k--')
%title('Theil Index')
%axis([1975,1997,0.06,0.12])

%figure %figBest
%subplot(3,1,1)
%plot(t20,bg(1:TT-1),'k',t20,rg(1:TT-1),'k--')
%title('GDP Growth')
%legend('Best Fit','Actual Data',2)
%axis([1975,1997,0,0.15])

%subplot(3,1,2)
%plot(tx,bf(1:TT),'k',tx,rf,'k--')
%title('Participation Rate')
%axis([1975,1997,0.05,0.3])

%subplot(3,1,3)
%plot(tx,bt(1:TT),'k',tx,rt,'k--')
%title('Theil Index')
%axis([1975,1997,0.06,0.12])

% Save
%save GJXi7cont xusq xasq xrsq amsru amsra amsrag amsraf amsrat amsragf amsragt amsraft; 
%save GJXi17cont xusq xasq xrsq amsru amsra amsrag amsraf amsrat amsragf amsragt amsraft;

%end

% Chi Sq figures
% check 100
hasq=xasq(1:(S/5));

% Simulated distribution
[sortAu,sortid]=sort(xusq);
[sortAa,sortid]=sort(xasq);
[sortAr,sortid]=sort(xrsq);
cAu=S*sortAu;
cAa=S*sortAa;
cAr=S*sortAr;

sortHa=sort(hasq);
cHa=S*sortHa;

dAa=cAa(2:S)-cAa(1:S-1);
dens=1/(S*dAa);
density=[0 dens];

% True distribution
q=linspace(1/S,0.999,S);
PP=chi2inv(q,p);
trueP=chi2cdf(PP,p); % This is for cdf
%trueP=chi2pdf(PP,57); % This is for pdf

% pdf==>measure problem!
for i=1:S
    cdp(i)=asorder(cAa',PP(i));
end
dcdp=cdp(2:S)-cdp(1:S-1);
pdp=([0 dcdp]+[dcdp 0])/2;

%figure
%hold on
%plot(cAu,q,'-.')
%plot(cAa,q,'-.')
%plot(PP,trueP)  % This is for true pdf picture
%hold off
%subplot(4,2,6+LG)
%plot(PP,trueP,cAr,q,'--')
%legend('\chi^{2}(57) Distribution','Simulated Distribution',2)
%axis([20,110,0,1])
csvwrite(out_file,  [amsra - 55]);
chi2sq = [amsra - 55];