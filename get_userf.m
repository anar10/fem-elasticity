function [f0, f1,f00, f01, f10, f11] = get_userf(ue, grad_ue, xe, problem_type)
%GET_USERF provides weak form of the problem to solve 
%
%  input:      ue: corresponding u for each element evalauted at quadrature points
%       : grad_ue: corresponding grad_u for each element evalauted at quadrature points (cell not matrix)
%       :      xe: quadrature points mapped to the reference elem
%
% output:  f0: any possible source from given problem
%       :  f1: any possible source from given problem
%       : f00: partial of f0 wrt u (algebriac operations only)
%       : f01: partial of f0 wrt grad_u (algebriac operations only)
%       : f10: partial of f1 wrt u (algebriac operations only)
%       : f11: partial of f1 wrt grad_u (algebriac operations only)


    x=xe(:,1);
    y=xe(:,2);
    sz_dim = size(xe,2);
    if(sz_dim == 3)
        z = xe(:,3);
    end


   % For L2-Projection problem:
   % Weak Form: (v: test/weight function)
   % integral(v*f0(ue,grad_ue) + grad_v : f1(ue,grad_ue)) = 0   

 if(strcmp(problem_type, 'L2') || strcmp(problem_type, 'l2'))     
     if(sz_dim == 2) %2D
        % RHS 
        g = tanh(x).*exp(y)+sin(y);

        f0 = ue - g;        
        f1 = 0*grad_ue;

        % partial_f0/partial_ue
        f00 = ones(size(f0,1),1);

        % partial_f0/partial_gradue
        f01 = zeros(size(f1,1),2);        

        %partial_f1/partial_ue
        f10 = zeros(size(f1,1),2);

        %partial_f1/partial_gradue
        f11 = zeros(size(f1,1),2);  
     elseif(sz_dim == 3) %3D         
        %RHS 
        g = tanh(x).*exp(y)+sin(y)+cos(z);

        f0 = ue - g; 
        f1 = 0*grad_ue;

        % partial_f0/partial_ue
        f00 = ones(size(f0,1),1);

        % partial_f0/partial_gradue
        f01 = zeros(size(f1,1),3); 


        % partial_f1/partial_ue
        f10 = zeros(size(f1,1),3);

        % partial_f1/partial_gradue
        f11 = zeros(size(f1,1),3);       
     end    
 elseif(strcmp(problem_type, 'Poisson') || strcmp(problem_type, 'poisson'))
     if(sz_dim == 2) %2D
        %RHS
        g=sin(y)+exp(y).*tanh(x)-exp(y).*tanh(x).^3.*2.0;

        f0 = 0*ue -g; 
        f1 = grad_ue;

        % partial_f0/partial_ue
        f00 = zeros(size(f0,1),1);

        % partial_f0/partial_gradue
        f01 = zeros(size(f0,1),2);   

        % partial_f1/partial_ue
        f10 = zeros(size(f1,1),2); 

        % partial_f1/partial_gradue    
        f11 = ones(size(f1,1),2);
     elseif(sz_dim == 3) %3D
        % RHS 
        g=cos(z)+sin(y)+exp(y).*tanh(x)-exp(y).*tanh(x).^3.*2.0;

        f0 = 0*ue -g; 
        f1 = grad_ue;

        % partial_f0/partial_ue
        f00 = zeros(size(f0,1),1);

        % partial_f0/partial_gradue
        f01 = zeros(size(f0,1),3); 

        % partial_f1/partial_ue
        f10 = zeros(size(f1,1),3);

        % partial_f1/partial_gradue     
        f11 = ones(size(f1,1),3);
     end
 elseif(strcmp(problem_type, 'Plane Strain') || strcmp(problem_type, 'plane strain'))   

    % Young's modulus 
    E = 2e11;
    % Poisson ratio 
    nu = 0.3;
    %strain/stress matrix
    C =(E/((1+nu)*(1-2*nu)))*[1-nu,nu,0; nu,1-nu,0; 0,0,(1-2*nu)/2];

    %grad_ue(:,1) = partial_u1/partial_x
    %grad_ue(:,2) = partial_u1/partial_y 
    %grad_ue(:,3) = partial_u2/partial_x
    %grad_ue(:,4) = partial_u2/partial_y 

    %strain = [partial_u1/partial_x, partial_u2/partial_y, 2*(partial_u2/partial_x + partial_u1/partial_y)]   
    strain = [grad_ue(:,1), grad_ue(:,4), 2*(grad_ue(:,3)+grad_ue(:,2))];     

    %stress (sigma) = (strain/stress matrix)*strain 
    sigma = strain*C';

    %RHS
    g1= -(E.*(nu-1.0./2.0).*(sin(y).*-2.0+exp(y).*tanh(x).*2.0+sin(y).*(tanh(x).^2-1.0).*2.0))./((nu.*2.0-1.0).*(nu+1.0))+(E.*nu.*sin(y).*(tanh(x).^2-1.0))./((nu.*2.0-1.0).*(nu+1.0))-(E.*exp(y).*tanh(x).*(tanh(x).^2-1.0).*(nu-1.0).*2.0)./((nu.*2.0-1.0).*(nu+1.0));
    g2= (E.*(exp(y).*(tanh(x).^2-1.0).*2.0-cos(y).*tanh(x).*(tanh(x).^2-1.0).*4.0).*(nu-1.0./2.0))./((nu.*2.0-1.0).*(nu+1.0))-(E.*nu.*exp(y).*(tanh(x).^2-1.0))./((nu.*2.0-1.0).*(nu+1.0))+(E.*cos(y).*tanh(x).*(nu-1.0))./((nu.*2.0-1.0).*(nu+1.0));

    f0(:,1) = -g1;
    f0(:,2) = -g2;
    f1 = [sigma(:,1), sigma(:,3), sigma(:,3), sigma(:,2)];

    % partial_f0/partial_ue
    f00 = zeros(size(f0,1),4);

    % partial_f0/partial_gradue
    f01 = zeros(size(f0,1),4);

    % partial_f1/partial_ue
    f10 = zeros(size(f1,1),4);

    % partial_f1/partial_gradue
    vecOne = ones(size(f1,1),3);
    f1_gu = vecOne*C';
    f11 = [f1_gu(:,1), f1_gu(:,3), f1_gu(:,3), f1_gu(:,2)];
 end
 
             
end

