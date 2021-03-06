function h = get_hsz(msh)
%GET_HSZ returns the size of the largest element in mesh:
%     
%input: msh (mesh)
%
%output: h: 
%          2D: maximum of the largest diagnoal of each element
%          3D: maximum of the largest diagnoal of each element
    
    dim = msh.num_dims;
    vtx = msh.vtx_coords;
    conn = msh.conn;
    if(dim == 2)
        if(msh.num_nodes_per_elem == 4)
            d1 = sqrt((vtx((conn(:,1)),1) - vtx((conn(:,4)),1)).^2 + (vtx((conn(:,1)),2) - vtx((conn(:,4)),2)).^2);
            d2 = sqrt((vtx((conn(:,2)),1) - vtx((conn(:,3)),1)).^2 + (vtx((conn(:,2)),2) - vtx((conn(:,3)),2)).^2);
            aved1 = mean(d1);
            aved2 = mean(d2);
        end
        if(msh.num_nodes_per_elem == 9)
             d1 = sqrt((vtx((conn(:,1)),1) - vtx((conn(:,9)),1)).^2 + (vtx((conn(:,1)),2) - vtx((conn(:,9)),2)).^2);
             d2 = sqrt((vtx((conn(:,3)),1) - vtx((conn(:,7)),1)).^2 + (vtx((conn(:,3)),2) - vtx((conn(:,7)),2)).^2);
            aved1 = mean(d1);
            aved2 = mean(d2);
        end
        h = max([aved1,aved2]);
    end    
    if(dim == 3)   
        if(msh.num_nodes_per_elem == 8)
            d1 = sqrt((vtx((conn(:,1)),1) - vtx((conn(:,8)),1)).^2 + (vtx((conn(:,1)),2) - vtx((conn(:,8)),2)).^2  + (vtx((conn(:,1)),3) - vtx((conn(:,8)),3)).^2);
            d2 = sqrt((vtx((conn(:,2)),1) - vtx((conn(:,7)),1)).^2 + (vtx((conn(:,2)),2) - vtx((conn(:,7)),2)).^2  + (vtx((conn(:,2)),3) - vtx((conn(:,7)),3)).^2);
            d3 = sqrt((vtx((conn(:,3)),1) - vtx((conn(:,6)),1)).^2 + (vtx((conn(:,3)),2) - vtx((conn(:,6)),2)).^2  + (vtx((conn(:,3)),3) - vtx((conn(:,6)),3)).^2);
            d4 = sqrt((vtx((conn(:,4)),1) - vtx((conn(:,5)),1)).^2 + (vtx((conn(:,4)),2) - vtx((conn(:,5)),2)).^2  + (vtx((conn(:,4)),3) - vtx((conn(:,5)),3)).^2);
            aved1 = mean(d1);
            aved2 = mean(d2);
            aved3 = mean(d3);
            aved4 = mean(d4);
        end
        if(msh.num_nodes_per_elem == 27)
            d1 = sqrt((vtx((conn(:,1)),1) - vtx((conn(:,27)),1)).^2 + (vtx((conn(:,1)),2) - vtx((conn(:,27)),2)).^2  + (vtx((conn(:,1)),3) - vtx((conn(:,27)),3)).^2);
            d2 = sqrt((vtx((conn(:,3)),1) - vtx((conn(:,25)),1)).^2 + (vtx((conn(:,3)),2) - vtx((conn(:,25)),2)).^2  + (vtx((conn(:,3)),3) - vtx((conn(:,25)),3)).^2);
            d3 = sqrt((vtx((conn(:,7)),1) - vtx((conn(:,21)),1)).^2 + (vtx((conn(:,7)),2) - vtx((conn(:,21)),2)).^2  + (vtx((conn(:,7)),3) - vtx((conn(:,21)),3)).^2);
            d4 = sqrt((vtx((conn(:,9)),1) - vtx((conn(:,19)),1)).^2 + (vtx((conn(:,9)),2) - vtx((conn(:,19)),2)).^2  + (vtx((conn(:,9)),3) - vtx((conn(:,19)),3)).^2);
            aved1 = mean(d1);
            aved2 = mean(d2);
            aved3 = mean(d3);
            aved4 = mean(d4);
        end 
        h = max([aved1,aved2,aved3,aved4]);
    end
