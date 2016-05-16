function [global_res , jac] = eval_res(u, global_idx_map, msh, dir_bndry_val)
% EVAL_RES evaluates the global residual and the Jacobian
%  input:              u: vector of unknowns 
%       : global_idx_map: global map of local u's
%       :            msh: mesh object (see get_mesh function)
%       :  dir_bndry_val: Dirchlet boundary values if any
%
% output: global_res, jac

     %get the numBr of elements
     num_elem = msh.num_elem; 
     
     %get connectivity matrix
     conn = msh.conn;
     
     %get vertex coordinates
     vtx_coords = msh.vtx_coords;
     
     %unknown size (size of dofs per unknown u)
     unknown_sz = size(u,1);
     
     %Allocate space for global residual for unkowns     
     global_res =zeros(unknown_sz,1);
     
     %get all dirichlet boundary node_sets
     dir_bndry_nodes = get_all_dir_ns(msh);
      
     global_u =  get_global_u(u,dir_bndry_nodes,dir_bndry_val,global_idx_map);     
   
     %Allocate space for globall Jacobian
     jac = zeros(unknown_sz,unknown_sz);
     
     %get size of dofs per node
     sz_global_idx_map = size(global_idx_map,2);
     
     %get element type    
     elm_type = msh.num_nodes_per_elem; 
     %get Weights, Basis (B) functions and their Derivatives (D0, D1 and D2)
     [B, Ds, W_hat] = get_shape(elm_type);
               
     for i=1:num_elem
         
         %get numBr of dof for each element
         neldof = size(conn(i,:),2)*sz_global_idx_map;
          
         %get corresponding vertex coordinates for each element 
         element_vtx_coords = vtx_coords(conn(i,:),:);
         
         %get corresponding unknown/solution u for each element
         elem_u = global_u(conn(i,:),:);   
         
         %get mapping constituents from jacobian
         [dets, invJe] = jacobian(element_vtx_coords, Ds);         
         Di = get_elem_dirv(invJe, Ds);
                 
         ue = B*elem_u;
         
         grad_ue=cell(1,size(Di,2));
         for  j=1:size(Di,2)
             grad_ue{j}=Di{j}*elem_u;
         end
                  
         mp_qd_pts= B*element_vtx_coords;
         
        [f0,f1,f00, f01, f10, f11] = userf(ue, grad_ue,mp_qd_pts); 
                 
         %get Gauss Weights for the current element
         W = W_hat.*dets';
                  
         D_res = zeros(size(f1{1}));
         wf1 = zeros(size(f1{1}));
         for j=1:size(Di,2)
             for k=1:size(f1,2)
                 wf1(:,k) = W.*f1{j}(:,k);
             end            
                 D_res = D_res + Di{j}'*wf1;
         end
         
          
         wf0 = zeros(size(f0{1},1), size(f0,2));
         for k=1:size(f0,2)
             wf0(:,k) = W.*f0{k};
         end 
         
         % element residual evaluation
         res_e = B'*wf0 + D_res;
                      
         %element jac_e constituents
         f0u = B'*diag(W.*f00)*B;
         
         f01TD =0;
         for j=1:size(Di,2) 
            f01TD = f01TD + diag(f01{j})*Di{j};
         end
         f0gu = B'*diag(W)*f01TD;
         
         f1u = 0;
         for j=1:size(Di,2) 
            f1u = f1u + Di{j}'*diag(W.*f10{j})*B;
         end
         
         f1gu = 0;
         for j=1:size(Di,2)
            f1gu = f1gu + Di{j}'* diag(W.*f11{j})*Di{j}; 
         end
         
         % element consistant tnagent evaulation (jac_e)
         jac_e = f0u + f0gu + f1u + f1gu;           
         
         % global residual and jacobian assembly 
         temp=conn(i,:)';
         k=1:neldof;
         kk=temp(k);
         in_glb = global_idx_map(kk);
         kk =in_glb(in_glb~=0);
         %global residual
         global_res(kk) = global_res(kk)+ res_e(in_glb~=0); 
         %global jacobian 
         jac(kk,kk)=jac(kk,kk)+jac_e(in_glb~=0, in_glb~=0);              
    
     end
end