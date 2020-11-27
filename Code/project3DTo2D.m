function projected2DPoints  = project3DTo2D(cam, worldCoord3DPoints) 

    % Initialize
    projected2DPoints = zeros(2, length(worldCoord3DPoints));
    for i = 1:length(worldCoord3DPoints)
       projectedPoint = cam.Kmat * cam.Pmat * worldCoord3DPoints(:, i);
       projectedPoint = projectedPoint(1:2)./projectedPoint(3);
       projected2DPoints(:, i) = projectedPoint;
    end
    
end 