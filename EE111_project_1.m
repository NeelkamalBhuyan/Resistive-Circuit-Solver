prompt = {'Enter the branches'};
dlgtitle = 'Initialise';    %dialog box title
dims = [1 35];                  %dimensions of input boxes
definput = {'5'};               %default input
answer = inputdlg(prompt,dlgtitle,dims,definput);       %input row matrix
n = str2num(answer{1})
E = ["R"];                      %stores type of element
V = [100];                      %stores value of voltage source/current source/resistance
N = [;];                        % 2xN matrix containg the two nodes of each element in numerical value

Vcount = 0;                     %number of voltage sources
Icount = 0;                     %number of current sources

for i = 1:n
    prompt = {'type of element', 'value', 'positive and negative node'};
    dlgtitle = 'Branch parameters';
    dims = [1 35];
    definput = {'RIV', '100', '1;2'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    E(1,i) = (answer{1});                               %row matrix storing the type of element in the ith column
    if E(1,i) == "V"
        Vcount = Vcount + 1;
    elseif E(1,i) == "I"        
        Icount = Icount + 1;
    end    
    V(1,i) = str2double(answer{2});                     %row matrix storing the type of element in the ith column                 
    N      = [N str2num(answer{3})];                    %2xN matrix containg the two nodes of each element in numerical value
end

no = max(max(N))                                        %to calculate total nodes, we find highest nide number

%K = zeros(1, no)                                        row matrix of zeroes, stores number of times ith node has occured

M = [N(1,:) N(2,:)]                                     
A = [1 : no]                                            %node number row matrix



G = zeros(no,no);                                       % G is the conductance matrix
C = zeros(Vcount,no);                                   % C is the transpose of B
B = zeros(no,Vcount);                                   % B contains how voltage source is connected to each of its terminals (+ve/-ve)
Z = zeros(1,(no+Vcount));                               % Z contains contains the value of current and voltage sources                         
vs = 1;                                                 %counter
for i = 1:n                                             %for loop for constructing the G,B and Z matrices
    n1 = N(1,i);
    n2 = N(2,i);                                        
    if E(1,i) == "R"
        G(n1,n2) = G(n1,n2) - 1/V(1,i);
        G(n2,n1) = G(n2,n1) - 1/V(1,i);
        G(n1,n1) = G(n1,n1) + 1/V(1,i);
        G(n2,n2) = G(n2,n2) + 1/V(1,i);
       
    elseif E(1,i) == "V"
        B(n1,vs) = 1;
        B(n2,vs) = -1;
        Z(1,(no+vs)) = V(1,i);
        vs = vs + 1;
       
    else
        Z(1,n1)=Z(1,n1) + V(1,i);
        Z(1,n2)=Z(1,n2) - V(1,i);
       
    end
end

C = transpose(B)
Z1 = transpose(Z)
z0 = zeros(Vcount)

Am = [G B;C z0]                                     
Am(1,:) = []                                            % taking the fist node as grounded we remove the column and row corresponding to it from Am and Z1                                                           
Am(:,1) = []
Z1(1,:) = []                                        

Ans = Am\Z1  % solving matrix equation, in the column matrix of Ans, we first display,from top node voltages and then the currents through voltage sources, eg:- Ans transpose=[V_node2 V_node3 I_voltsource] for a 3 node 1 voltage source system