function f = Metric_our ( x , Path_UpsampledData)
%% Camera Exposure Control for Robust Robot Vision with Noise-Aware Image Assessment Metric
%
% Ukcheol Shin, Jinsun Park, Gyumin Shim, Francois Rameau, and In So Kweon
%
% IROS 2019
%
% Please feel free to contact if you have any problems.
% 
% E-mail : Ukcheol Shin (shinwc159@gmail.com / shinwc159@kaist.ac.kr)
%          Robotics and Computer Vision Lab., EE,
%          KAIST, Republic of Korea
%
% Project Page : https://sites.google.com/view/noise-aware-exposure-control
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Name   : 
%    Metric_our
%
%   Returns a value based on the proposed image evaluation method for the input point, 
%   which value is returned based on the "<dataset_name> _upsample.mat" generated by 
%   the previous "Metric_Evaluaotr.m" and "Data_Interpolation.m" .
% 
%  Modified:
%
%    04 December 2019
%
%  Author:
%
%    Ukcheol Shin
%
%  Parameters:
%
%  Input    : x   -  input point, the dimension of x is 2x1,
%                      we assume x(1) component is "gain", x(2) component is "exposure time". 
%  output  : f_x -  Evaluated value based on our metric
%                      with given input parameter (gain, exposure time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  if ( length ( x ) ~= 2 )
    error ( 'Error: function expects a two dimensional input\n' );
  end
  
   % load upsampled dataset. 
   % In this code, we use pre-calculated datapoint and evaluated value of each dataset. 
    persistent Xq Yq Zq Interval_Up_Gain Interval_Up_ExpT result_txt;
    if ( nargin == 2 )
        load(Path_UpsampledData,'Xq','Yq','Zq', 'interval_ExpT','interval_dB');
        Interval_Up_Gain = interval_dB;
        Interval_Up_ExpT = interval_ExpT;
        result_txt = strcat(Path_UpsampledData(1:regexp(Path_UpsampledData,'workspace')-1), 'Traj_ExpTGain.txt');
        fileID = fopen(result_txt,'w');
        fclose(fileID);
    else
        fileID = fopen(result_txt,'a');
        fprintf(fileID , '%4.5f %4.5f\n' , x(1) , x(2));
        fclose(fileID);
    end
    
    Gain = x(1);
    Expt = x(2);
    
    if(mod(Gain, Interval_Up_Gain) >= Interval_Up_Gain/2)
        Approxi_Gain = Gain - mod(Gain, Interval_Up_Gain) + Interval_Up_Gain;
    elseif(mod(Gain, Interval_Up_Gain) < Interval_Up_Gain/2)
        Approxi_Gain = Gain - mod(Gain, Interval_Up_Gain);
    end

    if(mod(Expt, Interval_Up_ExpT) >= Interval_Up_ExpT/2)
        Approxi_Expt = Expt - mod(Expt, Interval_Up_ExpT) + Interval_Up_ExpT;
    elseif(mod(Expt, Interval_Up_ExpT) < Interval_Up_ExpT/2)
       Approxi_Expt = Expt - mod(Expt, Interval_Up_ExpT);
    end
        
    Gain_index = find(abs(Xq(1,:) - Approxi_Gain) < 0.001);
    ExpT_index = find(abs(Yq(:,1) - Approxi_Expt) < 0.001);
    
    f =  -Zq(ExpT_index,Gain_index);
    
    % Exception handler for out of range or nonexistent values.
    if(isnan(f)) 
        f = 10^10;  % instead of using "inf", use some large number
    elseif(isempty(f))
        f = 10^10;
    end
    
      fprintf ( 1, '  %9.3f',  Approxi_Gain );
      fprintf ( 1, '  %9.3f',  Approxi_Expt );
      fprintf ( 1, '  %9.3e\n', f );

    return 
end