function path = AStarPath(map, start_pos, end_pos)
    path = 0;
    % Start node
    start_node = Node(start_pos, 0);  
    start_node.g = 0;   % g - distance between current and start node
    start_node.h = 0;   % h - heuristics, approximation of the cost from current to end node
    start_node.f = 0;   % f - total cost of the node
    % End node
    end_node = Node(end_pos, 0);      
    end_node.g = 0;
    end_node.h = 0;
    end_node.f = 0;

    % Lists
    open_list = [];
    closed_list = [];
    open_list = [open_list, start_node];  % add the starting node to the open list

    while(~isempty(open_list))  % while there are still open nodes, go through them
        current_node = open_list(1);
        n = size(open_list);
        % Look for the best way in the open list and set the node to current
        for i = 1:n(2)  
            if(open_list(i).f < current_node.f)   % a better way found
                current_node = open_list(i);         
            end  
        end
        
        % Move the current node to closed
        closed_list = [closed_list, current_node];  % append current node to the closed list
        for idx = 1:size(open_list, 2)
            if(isequal(current_node.position, open_list(idx).position))
               open_list(idx) = []; % delete the node from open list
               break;
            end
        end

        % if end reached
        if isequal(current_node.position, end_node.position)
            disp("End reached");
            path = [];
            node_pointer = current_node;
            while(~isequal(node_pointer.position, start_node.position))
                path = [path; node_pointer.position];
                node_pointer = node_pointer.parentNode;
            end
            path = [path; start_pos];
            path = flip(path);
            return;
        end

        % Create children nodes, calculate their costs
        % - add them to open list if they are new positions 
        % - if the position is already there, check if the current cost is
        % lower
        % - if lower, update it in the list... if not, skip the node and do
        % not add to list neither update values
        directions = [[-1,-1]; [1,-1]; [-1,1]; [1, 1]; [-1,0]; [0,-1]; [0, 1]; [1, 0]];
        for i=1:size(directions,1)     
            new_position = current_node.position + directions(i,:);
            % Do not create a child if outside the map or is an obstacle
            if (new_position(1)> size(map,1))||(new_position(2)>size(map, 2))||(new_position(1)<=0)||(new_position(2)<=0)  % if outside of map or obstacle
                continue;               
            else
                % Skip obstacles
                if (map(new_position(1), new_position(2))== 1)             
                    continue;
                end
                child = Node(new_position, current_node);
                
                % If the node is already closed, skip it
                if(is_in_list(child, closed_list))
                    continue;
                end
                
                % Euclidean distance without sqrt
                distance_to_end = ((end_pos(1)-child.position(1))^2 + (end_pos(2)-child.position(2))^2); % euclidian distance 
                % Diagonal distance
                %distance_to_end = 10*(max(end_pos(1)-child.position(1), end_pos(2)-child.position(2)) - min(end_pos(1)-child.position(1), end_pos(2)-child.position(2)))+14*min(end_pos(1)-child.position(1), end_pos(2)-child.position(2)); % euclidian distance 
                
                if(i<=4)  % the diagonal neighbors have 14 as approx. interger distance sqrt(2)
                    child.g = current_node.g + 14;  % distance to current node + the distance to the child
                else      % the direct neighbors get 10 as 1
                    child.g = current_node.g + 10;  % distance to current node + the distance to the child
                end
                child.h = distance_to_end;     % estimated distance from child to the end node
                child.f = child.g + child.h;   % total cost of the node
               
                % Now check if the child is in the open list. If not, add
                % always. If it is, do not add and instead update f value
                % if a child.f is lower
                if(is_in_list(child, open_list))                 
                    index = get_node_idx(child.position, open_list);  % get index in the open list
                    % check if the cost (f value) in the list is lower
                    if child.g < open_list(index).g
                        % update f value, a better way to the position found
                        open_list(index).g = child.g;   % update the g value
                        open_list(index).parentNode = child.parentNode;  % update the parent
                    else
                        % skip
                        continue;
                    end
                % Add new node to the list
                else
                    open_list = [open_list, child];  % if position not in the open or closed list, add
                end
                

            end  
        end
    end
end


% Function checks if the current node is in the list (position comparison)
% 1 - is there, 0 - is not there
function open = is_in_list(current_node, open_list)
    open = 0;
    if(isempty(open_list))  % if the list is empty, directly return 0
        open = 0;
        return
    end
    for i=1:size(open_list,2)
        if isequal(open_list(i).position, current_node.position)
            open = 1;  % position found
        end
    end
end

% Function which returns the node index from a list according to a given position
function index = get_node_idx(position, list)
    index = -1;
    for idx = 1:size(list, 2)
        if(isequal(position, list(idx).position))
           index = idx;
           break;
        end
    end
end
