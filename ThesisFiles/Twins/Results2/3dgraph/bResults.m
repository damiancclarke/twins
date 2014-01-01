X=csvread('ZScore2.csv');

x=X(:,1);
y=X(:,2);
z=X(:,3);
e=X(:,5);

a=find(z<-0.1);
b=find(z>=-0.1 & z<-0.05);
c=find(z>=-0.05 & z<0);
d=find(z>=0 & z<0.25);
ee=find(z>=0.25 & z<0.5);
f=find(z>=0.5);

h=plot3(x(a),y(a),z(a),'ob');
      hold on
      plot3(x(b),y(b),z(b),'og');
      plot3(x(c),y(c),z(c),'oy');
      plot3(x(d),y(d),z(d),'or');
      plot3(x(ee),y(ee),z(ee),'or');
      plot3(x(f),y(f),z(f),'or');

for i=1:length(x(a))
        xVa = [x(a(i)); x(a(i))];
        yVa = [y(a(i)); y(a(i))];
        zMina = z(a(i)) + e(a(i));
        zMaxa = z(a(i)) - e(a(i));

        zVa = [zMina, zMaxa];
        % draw vertical error bar
        h=plot3(xVa, yVa, zVa, '-b');
        set(h, 'LineWidth', 2);
end


for i=1:length(x(b))
        xVb = [x(b(i)); x(b(i))];
        yVb = [y(b(i)); y(b(i))];
        zMinb = z(b(i)) + e(b(i));
        zMaxb = z(b(i)) - e(b(i));

        zVb = [zMinb, zMaxb];
        % draw vertical error bar
        h=plot3(xVb, yVb, zVb, '-g');
        set(h, 'LineWidth', 2);
end
for i=1:length(x(c))
        xVc = [x(c(i)); x(c(i))];
        yVc = [y(c(i)); y(c(i))];
        zMinc = z(c(i)) + e(c(i));
        zMaxc = z(c(i)) - e(c(i));

        zVc = [zMinc, zMaxc];
        % draw vertical error bar
        h=plot3(xVc, yVc, zVc, '-y');
        set(h, 'LineWidth', 2);

end
for i=1:length(x(d))
        xVd = [x(d(i)); x(d(i))];
        yVd = [y(d(i)); y(d(i))];
        zMind = z(d(i)) + e(d(i));
        zMaxd = z(d(i)) - e(d(i));

        zVd = [zMind, zMaxd];
        % draw vertical error bar
        h=plot3(xVd, yVd, zVd, '-r');
        set(h, 'LineWidth', 2);
end
for i=1:length(x(ee))
        xVee = [x(ee(i)); x(ee(i))];
        yVee = [y(ee(i)); y(ee(i))];
        zMinee = z(ee(i)) + e(ee(i));
        zMaxee = z(ee(i)) - e(ee(i));

        zVee = [zMinee, zMaxee];
        % draw vertical error bar
        h=plot3(xVee, yVee, zVee, '-r');
        set(h, 'LineWidth', 2);
end
for i=1:length(x(f))
        xVf = [x(f(i)); x(f(i))];
        yVf = [y(f(i)); y(f(i))];
        zMinf = z(f(i)) + e(f(i));
        zMaxf = z(f(i)) - e(f(i));

        zVf = [zMinf, zMaxf];
        % draw vertical error bar
        h=plot3(xVf, yVf, zVf, '-r');
        set(h, 'LineWidth', 2);
end
set(gca,'YTickLabel',{' ' ,'Low Income' ,'Lower Middle', 'Upper Middle', ' '}, 'FontSize',12)
set(gca,'XTickLabel',{'OLS NC', 'OLS S', 'OLS H', 'IV NC', 'IV S', 'IV H', ' '}, 'FontSize',12)
set(gca,'LineWidth',1.5)
xlabel('Estimator', 'FontSize',20);
ylabel('Country Group', 'FontSize',20);
zlabel('\beta_{Fertility}', 'FontSize',16);
grid on;
%axis square
%axis xy

L = legend('\beta < -0.1', '-0.1 \leq \beta < -0.05', '-0.05 \leq \beta <0', '\beta \geq 0');

hold off

%matlab2tikz('mysphere.tikz', 'height', '\figureheight', 'width', '\figurewidth');


