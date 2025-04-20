Y_offset = 0.0;
Xminp = 0;
Xmxp = 1600;
fm = 1

plt = [];

y0=Y_offset+[L0(1:end).Y]'+1;
x0=[L0(1:end).X]';
plt(end+1)=plot(x0, y0, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0 0.4470 0.7410]); %, 'MarkerFacColor', Clr2(J,:)
plt(end+1)=plot(x0-3, y0, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0 0.4470 0.7410]); %, 'MarkerFacColor', Clr2(J,:)

x1 = [L1(1:end).X]';
y1 = Y_offset+(4-3./(1.+exp(-0.02*(x1-800.0))));
plt(end+1)=plot(x1, y1, 'sk', 'LineWidth',0.01,  'MarkerSize', 4.5,'MarkerFaceColor', [0.8500 0.3250 0.0980]); %, 'MarkerFacColor', Clr2(J,:)
plt(end+1)=plot(x1-3, y1, 'sk', 'LineWidth',0.01, 'MarkerSize', 6,'MarkerFaceColor', [0.8500 0.3250 0.0980]); %, 'MarkerFacColor', Clr2(J,:)

Msg=sprintf('Simulation time 00:%d:%02d',floor(dt*(KK-1)/60),mod(floor(dt*(KK-1)),60));
title(Msg);
axis([Xminp, Xmxp, 0.0, 5+Y_offset]);
grid on;
xlabel('X');
M(fm)=getframe(hFig);
fm=fm+1;