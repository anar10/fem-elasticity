%Solving Plane Strain problem using FEM with unstructured mesh
clear
clc
format short


%'square9_1e_s',  'square4', 'square4_100e_s','square4_400e_s'; 'disk9_114e_us'

 file_name_list{1} = {'disk4_169e_us', 'disk4_274e_us', 'disk4_641e_us', 'disk4_2598e_us' };
 file_name_list{2} = {'disk9_169e_us', 'disk9_274e_us', 'disk9_641e_us','disk9_2598e_us' };
%file_name_list{1} = {'disk4_169e_us'};

folderName='mesh_Dirich_only';

steps = 1;
vtk_filename='PlainStrain';
if ~exist('PlainStrainVTKfiles', 'dir')
    mkdir('PlainStrainVTKfiles')
end
vtk_dest_folder = 'PlainStrainVTKfiles';

addpath(fullfile(pwd,folderName));

files = cell(file_name_list);
for i=1:size(file_name_list,2)
    files{i} = get_files(folderName, file_name_list{i});
end

%Provide the number of quadrature points in 1D per element used per set of files
num_quadr_pts_in_1d=[2,3];
userf={@userf_planeStrain;@userf_planeStrain};
userdf={@userdf_planeStrain;@userdf_planeStrain};
max_iter_gmres = 80;
max_iter_nw = 10;
global_res_tol = 1.0e-8;
tol = 1.0e-9;
%jac_flag = 1;

for i=1:size(files,2)
    error = zeros(1,size(files{i},2));
    h = zeros(1,size(files{i},2)); 
    for j=1:size(files{i},2)        
        filenames = files{i}{j};
        ext = 'exo';
        [origConn,msh] = get_mesh(filenames,ext,'lex');
        elem_type = msh.num_nodes_per_elem;
        h(j) = get_hsz(msh);
        
        sz_u_field = 2;
            
        %get all Dirichlet boundary node sets
        dir_bndry_nodes = get_all_dir_ns(msh);
    
        %NOTE: modify userf function according to given_u
           given_u{1}=@(x,y)0.5.*exp(x).*sin(y) + 3.*y.^2;
           given_u{2}=@(x,y)x.^2 - 0.75.*exp(y).*sin(x);


        %Construct manufactured solution:
        %========================================================================================%
        %get vertex coordinates from mesh                                     
        vtx_coords = msh.vtx_coords;                                          
        %get constructed dir_bndry_vals and exac Solutions on remaining nodes 
        [dir_bndry_val, exactSol] = get_exact_sol(vtx_coords,dir_bndry_nodes, given_u);
        %========================================================================================%
        if(msh.num_dims == 2)
           if(msh.num_nodes_per_elem == 4)
                elemType = 'Quad4';
            end
            if(msh.num_nodes_per_elem == 9)
                elemType = 'Quad9';
            end       
        end
        elemTypeMsg = ['Mesh element type: ', elemType];
        disp(elemTypeMsg);
        numElmMsg = ['Number of elements in mesh: ',num2str(msh.num_elem)];
        disp(numElmMsg);
        %solver = {'gmres', max_iter_gmres,max_iter_nw,tol,global_res_tol,jac_flag};
        solver = {'gmres', max_iter_gmres,max_iter_nw,tol,global_res_tol};
        fem_sol =  get_fem_sol(vtk_dest_folder, vtk_filename, steps, origConn, msh, sz_u_field, dir_bndry_nodes, dir_bndry_val,num_quadr_pts_in_1d(i),userf{i},userdf{i},solver);
        error(j) = norm(exactSol - fem_sol)/norm(fem_sol); 
        L2ErrMsg = strcat('L2 Error: ', num2str(error(j)));
        disp(L2ErrMsg);
        disp('   ');
    end
    prb_title = 'Plain Strain: 2D';
        if(elem_type == 4)
            leg_enry_1 = 'FEM-QUAD4';
            lglg_factor_1 = 0.001;
            lglg_pwr_1 = h;
            lglg_factor_2 = 0.1;
            lglg_pwr_2 = h.^2;
            leg_enry_2 = 'O(h)';
            leg_enry_3 = 'O(h^2)';
        elseif(elem_type == 9)
            leg_enry_1 = 'FEM-QUAD9';
            lglg_factor_1 = 0.00001;
            lglg_pwr_1 = h.^2;
            lglg_factor_2 = 0.001;
            lglg_pwr_2 = h.^3;
            leg_enry_2 = 'O(h^2)';
            leg_enry_3 = 'O(h^3)';
        end
        subplot(1,2,i);
        loglog(h,error,'r-o', h,lglg_factor_1*(lglg_pwr_1),'r:',h, lglg_factor_2*(lglg_pwr_2),'b--');
        legend(leg_enry_1,leg_enry_2,leg_enry_3,'Location','northwest')
        title(prb_title)
        xlabel('h')
        ylabel('error')      
end

rmpath(fullfile(pwd,folderName));

    
