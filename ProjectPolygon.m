function [ distance, bInPolygon, ptInPlane, ptInPolygon, barys, barysInPolygon, distToPlane ] = ProjectPolygon( pts, ptProject )
%Project the ptProject into the polygon described by pts
%   pts is a 1x9 vector, xyz xyz xyz

    bInPolygon = true;
    ptInPlane = [0 0 0];
    ptInPolygon = [0 0 0];
    distance = 0;
    barys = [ 1 1 1 ] / 3;
    distToPlane = 0;

    % Polygon as a base point and two vectors
    p1x = pts(1);
    p1y = pts(2);
    p1z = pts(3);
    v21 = pts(4:6) - pts(1:3);
    v31 = pts(7:9) - pts(1:3);
    v2x = v21(1);
    v2y = v21(2);
    v2z = v21(3);
    v3x = v31(1);
    v3y = v31(2);
    v3z = v31(3);

    % Vector from point to corners of polygon
    vpp1 = ptProject - pts(1:3);
    vpp2 = ptProject - pts(4:6);
    vpp3 = ptProject - pts(7:9);

    vpp1x = vpp1(1);
    vpp1y = vpp1(2);
    vpp1z = vpp1(3);

    % Cross products
    v22 = v2x*v2x + v2y*v2y + v2z*v2z;
    v33 = v3x*v3x + v3y*v3y + v3z*v3z;
    v23 = v2x*v3x + v2y*v3y + v2z*v3z;
    v2pp1=v2x*vpp1x+v2y*vpp1y+v2z*vpp1z;
    v3pp1=v3x*vpp1x+v3y*vpp1y+v3z*vpp1z;

    eps = 1e-16;
    if abs(v22) < eps
        v22 = 1; % recover if v2 == 0
    end

    if abs(v33) < eps
        v33 = 1; % recover if v3 == 0
    end

    denom=(v33-v23*v23/v22);
    if abs(denom) < eps
        barys(2:3) = 1/3;	% recover if v23*v23==v22*v33
    else 
        barys(3)=(v3pp1-v23/v22*v2pp1)/denom;
        barys(2)=(v2pp1-barys(3)*v23)/v22;
    end

    barys(1) = 1 - sum(barys(2:3));

    % Reconstruct point
    ptInPlane(1) = p1x+barys(2)*v2x+barys(3)*v3x;
    ptInPlane(2) = p1y+barys(2)*v2y+barys(3)*v3y;
    ptInPlane(3) = p1z+barys(2)*v2z+barys(3)*v3z;

    % See if outside of plane
    indxI = [4 7 1];  % if bad one is 3, then i is 1 and ii is 4
    indxII = [7 1 4];
    iIndxBary = [2 3 1]; % if bad one is 3, then i is 1 and ii is 2
    iIIndxBary = [3 1 2];
    iOutside = find( barys < 0 );
    barysInPolygon = barys;

    mind = 1e30;
    % k is i+2
    for k = iOutside
        bInPolygon = false;

        ptsI = pts(indxI(k):indxI(k)+2); % i
        ptsII = pts(indxII(k):indxII(k)+2); % i+1

        % Point is outside of iPrev-iNext edge; project onto edge
        vvi = ptsII - ptsI;
        vppi = ptProject - ptsI;

        d12sq = sum( vvi.^2 ); % Length squared
        don12 = vvi * vppi'; % Dot product

        if don12 <= 0
            d2 = sum( (ptsI - ptProject).^2 ); % length squared
            if d2 < mind
                mind = d2; 
                barysInPolygon = [0 0 0];
                barysInPolygon( iIndxBary(k) ) = 1;
            end
        elseif don12 >= d12sq
            d2 = sum( (ptsII - ptProject).^2 ); % length squared
            if d2 < mind
                mind = d2; 
                barysInPolygon = [0 0 0];
                barysInPolygon( iIIndxBary(k) ) = 1;
            end
        else
            a = don12 / d12sq;
            ptEdge = ptsI + (ptsII - ptsI) * a;
            d2 = sum( (ptEdge - ptProject).^2 );
            if d2 < mind
                mind = d2;
                barysInPolygon = [0 0 0];
                barysInPolygon( iIndxBary(k) ) = 1 - a;
                barysInPolygon( iIIndxBary(k) ) = a;
            end
        end

    end

    ptInPolygon = barysInPolygon(1) * pts(1:3) + barysInPolygon(2) * pts(4:6) + barysInPolygon(3) * pts(7:9);

    distance = sqrt( sum( (ptProject - ptInPolygon).^2 ) );
    distToPlane = sqrt( sum( (ptProject - ptInPlane).^2 ) );

end

% %% From R2Polygon.cpp
%    WINbool bRet = FALSE;
%     out_ptTri = R3Pt(0,0,0);
% 
% 	const double p1x=m_apts[0][0], p1y=m_apts[0][1], p1z=m_apts[0][2];
% 	const double v2x=m_apts[1][0]-p1x, v2y=m_apts[1][1]-p1y, v2z=m_apts[1][2]-p1z;
% 	const double v3x=m_apts[2][0]-p1x, v3y=m_apts[2][1]-p1y, v3z=m_apts[2][2]-p1z;
% 	const double vpp1x=in_pt[0]-p1x, vpp1y=in_pt[1]-p1y, vpp1z=in_pt[2]-p1z;
% 	double v22=v2x*v2x+v2y*v2y+v2z*v2z;
% 	double v33=v3x*v3x+v3y*v3y+v3z*v3z;
% 	const double v23=v2x*v3x+v2y*v3y+v2z*v3z;
% 	const double v2pp1=v2x*vpp1x+v2y*vpp1y+v2z*vpp1z;
% 	const double v3pp1=v3x*vpp1x+v3y*vpp1y+v3z*vpp1z;
% 	if ( RNIsZero(v22) ) v22=1.0;	// recover if v2==0
% 	if ( RNIsZero(v33) ) v33=1.0;	// recover if v3==0
% 	double a2,a3;
% 	const double denom=(v33-v23*v23/v22);
% 	if ( RNIsZero(denom) ) {
% 		a2=a3=1.0/3.0;	// recover if v23*v23==v22*v33
% 	} else {
% 		a3=(v3pp1-v23/v22*v2pp1)/denom;
% 		a2=(v2pp1-a3*v23)/v22;
% 	}
%     out_adBary.need(3);
% 
% 	const double a1=1-a2-a3;
% 	out_adBary[0] = a1;
%     out_adBary[1] = a2;
%     out_adBary[2] = a3;
% 
% 	// Point clp=interp(p1,p2,p3,a1,a2);
% 	out_ptPlane[0] = p1x+a2*v2x+a3*v3x;
% 	out_ptPlane[1] = p1y+a2*v2y+a3*v3y;
% 	out_ptPlane[2] = p1z+a2*v2z+a3*v3z;
% 
%     Array<double> adBary(3);
% 	if (a1<0 || a2<0 || a3<0) {
% 	    // projection lies outside triangle, so more work is needed.
% 	    double mind2 = 1e30;
% 	    for (int i = 0; i < 3; i++) {
% 		    if ( out_adBary[(i+2)%3] >= 0 ) continue;
% 		    // project proj onto segment pf[(i+0)%3]--pf[(i+1)%3]
% 		    const R3Vec vvi = m_apts.wrap((i+1)%3) - m_apts[i];
% 		    const R3Vec vppi = out_ptPlane - m_apts[i];
% 
% 		    double d12sq = LengthSq(vvi);
% 		    double don12 = Dot(vvi,vppi);
% 		    if (don12 <= 0) {
% 			    double d2 = LengthSq( m_apts[i] - out_ptPlane );
% 			    if ( d2 >= mind2) continue;
% 			    mind2 = d2; 
%                 adBary[i] = 1.0;
%                 adBary.wrap(i+1) = adBary.wrap(i+2) = 0;
% 		    } else if ( don12 >= d12sq ) {
% 			    double d2 = LengthSq(m_apts.wrap(i+1) - out_ptPlane);
% 			    if (d2 >= mind2) continue;
% 			    mind2 = d2; 
%                 adBary.wrap(i+1) = 1.0;
%                 adBary[i] = adBary.wrap(i+2) = 0;
% 		    } else {
% 			    double a = don12 / d12sq;
% 			    adBary[i]=1.0 - a; 
%                 adBary.wrap(i+1) = a; 
%                 adBary.wrap(i+2) = 0;
% 			    break;
% 		    }
% 	    }
%         out_adBary = adBary;
%         for ( int j = 0; j < 3; j++ )
%             for ( int i = 0; i < 3; i++ )
%                 out_ptTri[j] += adBary[i] * m_apts[i][j];
%     
%     } else {
%         bRet = TRUE;
%         out_ptTri = out_ptPlane;
%     }
% 
%     out_dDistSq = LengthSq( out_ptTri - in_pt );
%     return bRet;
% }


