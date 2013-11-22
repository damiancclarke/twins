cd ~/investigacion/Activa/Twins

data=csvread('Data/desired_actual.csv');
desire=[1:1:10];
have=[1:1:10];
grid=NaN(10);


%**********************************************************************
%*** Total births for each desired/actual combination
%**********************************************************************
for p=1:10
	for q=1:10
		grid(p,q)=sum(data(:,1)==p&data(:,2)==q);
         end
end

graph=mesh(desire,have,grid)
title('Ability to achieve desired family size', 'FontSize', 16);
xlabel('Desired Family Size', 'FontSize', 14);
ylabel('Actual Family Size', 'FontSize', 14);

print -depsc 'Results/5Aug2013/Graphs/mesh_DesiredActual'

%**********************************************************************
%*** Total births for each desired/actual combination for >35 years
%**********************************************************************
grid=NaN(10);
for p=1:10
	for q=1:10
		grid(p,q)=sum(data(:,1)==p&data(:,2)==q&data(:,3)>35);
         end
end

graph=mesh(desire,have,grid)
title('Ability to achieve desired family size (Mothers > 35 years)',... 
    'FontSize', 16);
xlabel('Desired Family Size', 'FontSize', 14);
ylabel('Actual Family Size', 'FontSize', 14);

print -depsc 'Results/5Aug2013/Graphs/mesh_DesiredActual_35plus'

%**********************************************************************
%*** Fraction of births for each desired/actual combination
%**********************************************************************
grid=NaN(10);
for p=1:10
	for q=1:10
		grid(p,q)=sum(data(:,1)==p&data(:,2)==q)/sum(data(:,2)==q);
         end
end

graph=mesh(desire,have,grid) 
title('Ability to achieve desired family size', 'FontSize', 16);
xlabel('Desired Family Size', 'FontSize', 14);
ylabel('Actual Family Size', 'FontSize', 14);
zlabel('Fraction of Actial Family Size', 'FontSize' ,14)

print -depsc 'Results/5Aug2013/Graphs/mesh_DesiredActual_Frac'

%**********************************************************************
%*** Fraction of births for each desired/actual combination (>35)
%**********************************************************************
grid=NaN(10);
for p=1:10
	for q=1:10
		grid(p,q)=sum(data(:,1)==p&data(:,2)==q&data(:,3)>35)...
		/sum(data(:,2)==q&data(:,3)>35);
         end
end

graph=mesh(desire,have,grid)
title('Ability to achieve desired family size', 'FontSize', 16);
xlabel('Desired Family Size', 'FontSize', 14);
ylabel('Actual Family Size', 'FontSize', 14);
zlabel('Fraction of Actial Family Size', 'FontSize' ,14)

print -depsc 'Results/5Aug2013/Graphs/mesh_DesiredActual_Frac_35plus'



