function [] = timerCallback(~,~,guiHandle,hObject)
%% Function is called every X number of seconds to read from arduino and update plots
%
if ~isempty(guiHandle)
    % get the handles
    handles = guidata(guiHandle);
    if ~isempty(handles)
        % wait until there is enough information to be read
        while 1
            ba = handles.arduino.BytesAvailable;
            if ba >= 5
                break
            end
        end
        a = fscanf(handles.arduino, '%f');
        
        % check for start character
        while (a~= -10000)
            a = fscanf(handles.arduino, '%f');
            continue
        end
        
        
        % wait until all values have been recieved
        
        while 1
            ba = handles.arduino.BytesAvailable;
            if ba >= 16
                break
            end
        end
        
        % keep count of number of times all values have been recieved
        handles.curr = handles.curr + 1;
        lastwarn('')
        
        % read values from arduino
        ktemp = fscanf(handles.arduino, '%f');
        htemp = fscanf(handles.arduino, '%f');
        kt = fscanf(handles.arduino, '%f');
        ht = fscanf(handles.arduino, '%f');
        t = handles.t;
        [warnMsg, warnId] = lastwarn;
        % Error check for readings and handle error
        if ~isempty(warnMsg)
            ka = NaN;
            ha = NaN;
            kt = NaN;
            ht = NaN;
            t = handles.t;
            return;
        end
        % Convert degrees to radians
        ka = deg2rad(ktemp);
        ha = deg2rad(htemp);
        % flush out arduino to have latest results
        flushinput(handles.arduino);
        % Check to see if values make sense
        if (ka < -30 || ka > 30 || ha < -30 || ha > 30 || kt <= -30 || kt > 30 || ht <= -30 || ht > 30)
        else
            % plot results
            handles.HTstr1 = ['Q = ' num2str(ht) ' N*m'];
            handles.HTstr2 = ['Q = ' num2str(kt) ' N*m'];
            handles.HTstr3 = ['Q = ' num2str(0) ' N*m'];
            % apply forward kinematics
            ax = fk([ha; ka; 0]);
            
            
            [m, n] = size(ax);
            
            
            % get index of corresponding reference gait
            [index, erv] = err([ha, ka], handles.ref);
            har = handles.ref(index, 1);
            kar = handles.ref(index, 2);
            
            % apply forward kinematics to reference gait
            axr = fk([har; kar; 0]);
            
            % extract joint positions
            xk = ax([1, 2], 1);
            xa = ax([1, 2], 2);
            xt = ax([1, 2], 3);
            
            xkr = axr([1, 2], 1);
            xar = axr([1, 2], 2);
            xtr = axr([1, 2], 3);
            
            xAll = [zeros(size(xk)), xk, xa, xt];
            
            xAllr = [zeros(size(xkr)), xkr, xar, xtr];
            
            % save results so that it can be saved to a file later
            handles.axs(1, handles.curr) = ax(1);
            handles.axs(2, handles.curr) = ax(2);
            handles.axs(3, handles.curr) = ax(3);
            handles.axs(4, handles.curr) = ax(4);
            handles.axs(5, handles.curr) = ax(5);
            handles.axs(6, handles.curr) = ax(6);
            
            handles.xAlls(1, handles.curr) = xAll(1);
            handles.xAlls(2, handles.curr) = xAll(2);
            handles.xAlls(3, handles.curr) = xAll(3);
            handles.xAlls(4, handles.curr) = xAll(4);
            handles.xAlls(5, handles.curr) = xAll(5);
            handles.xAlls(6, handles.curr) = xAll(6);
            handles.xAlls(7, handles.curr) = xAll(7);
            handles.xAlls(8, handles.curr) = xAll(8);
            
            handles.xAllrs(1, handles.curr) = xAllr(1);
            handles.xAllrs(2, handles.curr) = xAllr(2);
            handles.xAllrs(3, handles.curr) = xAllr(3);
            handles.xAllrs(4, handles.curr) = xAllr(4);
            handles.xAllrs(5, handles.curr) = xAllr(5);
            handles.xAllrs(6, handles.curr) = xAllr(6);
            handles.xAllrs(7, handles.curr) = xAllr(7);
            handles.xAllrs(8, handles.curr) = xAllr(8);
            
            
            handles.kas = [handles.kas, ka];
            handles.kts = [handles.kts, kt];
            handles.has = [handles.has, ha];
            handles.hts = [handles.hts, ht];
            handles.ts = [handles.ts, t + 0.1];
            
            
            % Plot only the recent 10 ankle positions
            if (handles.curr > 10)
                xpos = get(handles.Pos(2,1),'XData');
                ypos = get(handles.Pos(2,1),'YData');
                xdata = [xpos(end - 10:end), ax(1,2)];
                ydata = [ypos(end - 10:end), ax(2,2)];
                set(handles.Pos(2,1),'XData',xdata,'YData',ydata);
            else
                xpos = get(handles.Pos(2,1),'XData');
                ypos = get(handles.Pos(2,1),'YData');
                xdata = [xpos, ax(1,2)];
                ydata = [ypos, ax(2,2)];
                set(handles.Pos(2,1),'XData',xdata,'YData',ydata);
            end
            
            %Plot only handles.limit recent values
            if (handles.curr > handles.limit)
                
                xdata = xAll([1 3 5 7]);
                ydata = xAll([2 4 6 8]);
                set(handles.sim(1,1),'XData',xdata,'YData',ydata);
                xdata = xAll([1 3 5 7]);
                ydata = xAll([2 4 6 8]);
                set(handles.sim(2,1),'XData',xdata,'YData',ydata);
                
                xdata = xAllr([1 3 5 7]);
                ydata = xAllr([2 4 6 8]);
                set(handles.sim(3,1),'XData',xdata,'YData',ydata);
                xdata = xAllr([1 3 5 7]);
                ydata = xAllr([2 4 6 8]);
                set(handles.sim(4,1),'XData',xdata,'YData',ydata);
                
                set(handles.Htext1, 'string', handles.HTstr1, 'position', xAll(1:2) + [0.03,0]);
                set(handles.Htext2, 'string', handles.HTstr2, 'position', xAll(3:4)+ [0.03,0]);
                set(handles.Htext3, 'string', handles.HTstr3, 'position', xAll(5:6));
                
                
                
                
                xpos = get(handles.Hka,'XData');
                ypos = get(handles.Hka,'YData');
                xdata = [xpos(end - handles.limit:end) t];
                ydata = [ypos(end - handles.limit:end) ka];
                set(handles.Hka,'XData',xdata,'YData',ydata);
                
                
                xpos = get(handles.Hkt,'XData');
                ypos = get(handles.Hkt,'YData');
                xdata = [xpos(end - handles.limit:end) t];
                ydata = [ypos(end - handles.limit:end) kt];
                set(handles.Hkt,'XData',xdata,'YData',ydata);
                
                
                xpos = get(handles.Hha,'XData');
                ypos = get(handles.Hha,'YData');
                xdata = [xpos(end - handles.limit:end) t];
                ydata = [ypos(end - handles.limit:end) ha];
                set(handles.Hha,'XData',xdata,'YData',ydata);
                
                
                xpos = get(handles.Hht,'XData');
                ypos = get(handles.Hht,'YData');
                xdata = [xpos(end - handles.limit:end) t];
                ydata = [ypos(end - handles.limit:end) ht];
                set(handles.Hht,'XData',xdata,'YData',ydata);
            else
                xdata = xAll([1 3 5 7]);
                ydata = xAll([2 4 6 8]);
                set(handles.sim(1,1),'XData',xdata,'YData',ydata);
                xdata = xAll([1 3 5 7]);
                ydata = xAll([2 4 6 8]);
                set(handles.sim(2,1),'XData',xdata,'YData',ydata);
                
                xdata = xAllr([1 3 5 7]);
                ydata = xAllr([2 4 6 8]);
                set(handles.sim(3,1),'XData',xdata,'YData',ydata);
                xdata = xAllr([1 3 5 7]);
                ydata = xAllr([2 4 6 8]);
                set(handles.sim(4,1),'XData',xdata,'YData',ydata);
                
                
                set(handles.Htext1, 'string', handles.HTstr1, 'position', xAll(1:2) + [0.03,0]);
                set(handles.Htext2, 'string', handles.HTstr2, 'position', xAll(3:4)+ [0.03,0]);
                set(handles.Htext3, 'string', handles.HTstr3, 'position', xAll(5:6));
                
                
                xdata = [get(handles.Hka,'XData') t];
                ydata = [get(handles.Hka,'YData') ka];
                set(handles.Hka,'XData',xdata,'YData',ydata);
                
                xdata = [get(handles.Hkt,'XData') t];
                ydata = [get(handles.Hkt,'YData') kt];
                set(handles.Hkt,'XData',xdata,'YData',ydata);
                
                xdata = [get(handles.Hha,'XData') t];
                ydata = [get(handles.Hha,'YData') ha];
                set(handles.Hha,'XData',xdata,'YData',ydata);
                
                xdata = [get(handles.Hht,'XData') t];
                ydata = [get(handles.Hht,'YData') ht];
                set(handles.Hht,'XData',xdata,'YData',ydata);
            end
            
            
            set(handles.karv, 'String', num2str(ka));
            set(handles.htnmv, 'String', num2str(ht));
            set(handles.ktnmv, 'String', num2str(kt));
            set(handles.harv, 'String', num2str(ha));
        end
        
        handles.t = t + 0.1;
        guidata(hObject,handles);
        
    end
end