function side_ss = get_all_side_ss(msh)
%GET_ALL_SIDE_SS returns all sidesets in one cell array.
%input: mesh
%output: All elements sidesets
   
    fld_names = fieldnames(msh);
    ss_names = fld_names((strncmp(fld_names,'side_ss',7)));

    for i=1:size(ss_names,1);
        if(strfind(ss_names{i},'_node'));        
            ss_names{i} = [];
        end
    end
    ss_names = ss_names(~cellfun('isempty',ss_names));
    
    sz_ss_names = size(ss_names,1);
    sz_side_ss = zeros(sz_ss_names,1);
    for i=1:sz_ss_names
       sz_side_ss(i) = size(msh.(ss_names{i}),1);
    end
    dir_ns_vec = zeros(sum(sz_side_ss),1);
    side_ss = mat2cell(dir_ns_vec, sz_side_ss);
      
    for i=1:sz_ss_names
        side_ss{i} = msh.(ss_names{i});
    end
   
end