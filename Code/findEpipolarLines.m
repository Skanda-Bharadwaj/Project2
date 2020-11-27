function  [EpipolarLines1, EpipolarLines2] = findEpipolarLines(worldCoord3DPoints, cam1, cam1PixelCoords, cam2, cam2PixelCoords)
    
    F = computeFundamentalMatrix(cam1PixelCoords, cam2PixelCoords);
    
    EpipolarLines1 = zeros(3, length(cam1PixelCoords));
    EpipolarLines2 = zeros(3, length(cam2PixelCoords));
    
    for i = 1:length(cam1PixelCoords)
       EpipolarLines2(:,i) = F*[cam1PixelCoords(:,i); 1]; 
       EpipolarLines1(:,i) = F'*[cam2PixelCoords(:,i); 1];  
    end
    
end

%%
function F = computeFundamentalMatrix(cam1ImageCoordinates, cam2ImageCoordinates)
    
    a1 = cam1ImageCoordinates(1,:).*cam2ImageCoordinates(1,:);
    a2 = cam1ImageCoordinates(1,:).*cam2ImageCoordinates(2,:);
    a3 = cam1ImageCoordinates(1,:);
    a4 = cam1ImageCoordinates(2,:).*cam2ImageCoordinates(1,:);
    a5 = cam1ImageCoordinates(2,:).*cam2ImageCoordinates(2,:);
    a6 = cam1ImageCoordinates(2,:);
    a7 = cam2ImageCoordinates(1,:);
    a8 = cam2ImageCoordinates(2,:);
    a9 = ones(1, length(cam1ImageCoordinates));
    A = [a1', a2', a3', a4', a5', a6', a7', a8', a9'];
    A = A(1:8,:);

    [~, ~, V] = svd(A);
    F = V(:,end);
    F = reshape(F, 3,3);
    
    [U, D, V] = svd(F);
    D(end,end) = 0; 
    F = U*D*V';

end