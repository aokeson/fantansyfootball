%Data downloaded from http://apps.fantasyfootballanalytics.net/projections
%How big do you want the 95% confidence interval to be?
%Specify upper and lower point value risk bounds
lowerRiskBound = 100;
upperRiskBound = 100;

[myPlayers myPlayersText] = xlsread('players.xls');
[myPlayersRows,myPlayersCols] = size(myPlayersText);
[allPlayers allPlayerNames] = xlsread('week14.xls');
[rows,cols] = size(allPlayers);

players = [];
playerNames = [];

for k=1:rows
    for m=1:myPlayersRows
        if strcmp(allPlayerNames(k),myPlayersText(m))
            players = [players;allPlayers(k,:)];
            playerNames = [playerNames;allPlayerNames(k)];
        end
    end
end

[rows,cols] = size(players);

f = -1*players(:,1);
    
intcon = 1:rows;
A = [];
b = [];
Aeq = [];
beq = [];
lb = zeros(rows,1);
ub = ones(rows,1);

% QB
Aeq = [Aeq;transpose(players(:,2))];
beq = [beq;1];

%RB
A = [A;transpose(players(:,3))];
b = [b;3];
A = [A;transpose(-1*players(:,3))];
b = [b;-2];

%WR
A = [A;transpose(players(:,4))];
b = [b;3];
A = [A;transpose(-1*players(:,4))];
b = [b;-2];

%TE
A = [A;transpose(players(:,5))];
b = [b;2];
A = [A;transpose(-1*players(:,5))];
b = [b;-1];

%K
Aeq = [Aeq;transpose(players(:,6))];
beq = [beq;1];

%D/ST
Aeq = [Aeq;transpose(players(:,7))];
beq = [beq;1];

%FLEX
flex = zeros(rows,1);
for i=1:rows
    if players(i,3)==1.0000
        flex(i)=1;
    elseif players(i,4)==1.0000
        flex(i)=1;
    elseif players(i,5)==1.0000
        flex(i)=1;
    end
end
Aeq = [Aeq;transpose(flex)];
beq = [beq;6];

%Risk
lowerRisk = zeros(rows,1);
upperRisk = zeros(rows,1);
for n=1:rows
    lowerRisk(n) = players(n,1)-players(n,9);
    upperRisk(n) = players(n,8)-players(n,1);
end
A = [A;transpose(upperRisk)];
b = [b;upperRiskBound];
A = [A;transpose(lowerRisk)];
b = [b;lowerRiskBound];


solution = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

upperRiskAcutal = 0;
lowerRiskAcutal = 0;
disp('Team for this week:');
for j=1:rows
    if solution(j)>0.5 
        upperRiskAcutal = upperRiskAcutal + upperRisk(j);
        lowerRiskAcutal = lowerRiskAcutal + lowerRisk(j);
        if players(j,2)==1.0000
            disp(strcat('Quarterback:',{' '},playerNames(j),' with score:',{' '},num2str(players(j,1))));
        elseif players(j,3)==1.0000
            disp(strcat('Running Back:',{' '},playerNames(j),' with score:',{' '},num2str(players(j,1))));
        elseif players(j,4)==1.0000
            disp(strcat('Wide Receiver:',{' '},playerNames(j),' with score:',{' '},num2str(players(j,1))));
        elseif players(j,5)==1.0000
            disp(strcat('Tight End:',{' '},playerNames(j),' with score:',{' '},num2str(players(j,1))));
        elseif players(j,6)==1.0000
            disp(strcat('Kicker:',{' '},playerNames(j),' with score:',{' '},num2str(players(j,1))));
        elseif players(j,7)==1.0000
            disp(strcat('Defense/Special Teams:',{' '},playerNames(j),' with score:',{' '},num2str(players(j,1))));
        end
    end
end
disp(strcat('Your upper bound is:',{' +'},num2str(upperRiskAcutal)));
disp(strcat('Your lower bound is:',{' -'},num2str(lowerRiskAcutal)));
