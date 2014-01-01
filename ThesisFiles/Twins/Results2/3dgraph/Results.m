X=csvread('YrSch1.csv');

x=X(:,1);
y=X(:,2);
z=X(:,3);
e=X(:,5);
col=X(:,6);

a=find(z<0)
b=find(z>0 & z<0.5)
c=find(z>0 & z<0.5)
d=find(z>=0.5 & z<1)
e=find(z>=1)

      plot3(x(a),y(a),z(a),'+r');
%      set(h, 'MarkerSize', 25);
      hold on
      plot3(x(b),y(b),z(b),'+y');
      plot3(x(c),y(c),z(c),'+c');
      plot3(x(d),y(d),z(d),'+b');
      plot3(x(e),y(e),z(e),'+k');

%set(h, 'MarkerSize', 25);



for i=1:length(x)
        xV = [x(i); x(i)];
        yV = [y(i); y(i)];
        zMin = z(i) + e(i);
        zMax = z(i) - e(i);

        zV = [zMin, zMax];
       % draw vertical error bar
        h=plot3(xV, yV, zV, '-k');
        set(h, 'LineWidth', 2);
end

% now we want to fit a surface to our data
% the  0.25 and 0.1 define the density of the fit surface
% adjust them to your liking
%tt1=[floor(min(min(x))):0.25:max(max(x))];
%tt2=[floor(min(min(y))):0.1:max(max(y))];

% prepare for fitting the surface
%[xg,yg]=meshgrid(tt1,tt2);

% fit the surface to the data; 
% matlab has several choices for the fit;  below is "linear"
%zg=griddata(x, y, z, xg,yg,'linear');
% draw the mesh on our plot
%mesh(xg,yg,zg), xlabel('x axis'), ylabel('y axis'), zlabel('z axis')
