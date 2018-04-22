clf;
%%
fprintf(s, 's'); % start sending data

while 1
    ba = s.BytesAvailable;
    if ba >= 4
        break
    end
end

out = fscanf(s, '%f');
while (out~= -10000)
    out = fscanf(s, '%f');
    continue
end

%% start retrieving data
t = fscanf(s, '%f');
Q = fscanf(s, '%f');

while 1
    while 1
        ba = s.BytesAvailable;
        if ba >= 4
            break
        end
    end
    
    out = fscanf(s, '%f');
    if out == -5000
        break;
    elseif out == -10000
        while 1
            ba = s.BytesAvailable;
            if ba >= 8
                break
            end
        end
        t = [t; fscanf(s, '%f')];
        Q = [Q; fscanf(s, '%f')];
    end
end

%% plot

figure(1);
plot((t-t(1))/1000000, abs(Q), 'k');
hold on;
plot((t-t(1))/1000000, (1:length(t))*10/length(t), '--r');
hold on;
%plot((t-t(1))/1000000, (linspace(1, length(t), length(t))*10/length(t))-0.5, '--b');
title('Torque Step Response');
xlabel('Time (s)');
ylabel('Torque (Nm)');
%legend('Actual Torque', 'Desired Torque', 'Location', 'SouthEast');
xlim([0, 3]);

%%
file = 'TSR_lin_16';
save(file);