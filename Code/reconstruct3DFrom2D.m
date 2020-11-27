function recovered3DPoints = reconstruct3DFrom2D(cam1, cam1PixelCoords, cam2, cam2PixelCoords)
    recovered3DPoints = zeros(4, length(cam1PixelCoords));
    
    % Create projection matrix
    cam1ProjectionMatrix = cam1.Kmat * cam1.Pmat;
    cam2ProjectionMatrix = cam2.Kmat * cam2.Pmat;
    
    for i = 1:length(cam1PixelCoords)
       cam1Coordinates = cam1PixelCoords(:,i);
       cam2Coordinates = cam2PixelCoords(:,i);
      
       % Construct A
       A1 = [cam1Coordinates(2)*cam1ProjectionMatrix(3,:) - cam1ProjectionMatrix(2,:); ...
             cam1ProjectionMatrix(1,:) - cam1Coordinates(1)*cam1ProjectionMatrix(3,:)];
         
       A2 = [cam2Coordinates(2)*cam2ProjectionMatrix(3,:) - cam2ProjectionMatrix(2,:); ...
             cam2ProjectionMatrix(1,:) - cam2Coordinates(1)*cam2ProjectionMatrix(3,:)];
        
       % Eigen Decomposition
       A = [A1;A2]; 
       B = A'*A;
       [V, ~] = eigs(B);
       
       % Normalize
       recovered3DPoints(:,i) = V(:,4)./V(4,4)';
    end
end