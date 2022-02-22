%This file is part of TEAP.
%
%TEAP is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%
%TEAP is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with TEAP.  If not, see <http://www.gnu.org/licenses/>.
% 
%> @file RES_aqn_variable.m
%> @brief RES_aqn_variable gets a RES signal from a variable
% 
%> @param rawRES [1xN]: the raw RES signal
%> @param sampRate [1x1]: the sampling rate, in Hz
% 
%> @retval Signal: A RES TEAP signal
%> @author Copyright Frank Villaro-Dixon, 2014
function Signal = RES_aqn_variable(rawRES, sampRate)

if(nargin ~= 2)
	error('Usage: RES_aqn_variable(rawRes, sampRate');
end

Signal = RES__new_empty();
Signal = Signal__set_samprate(Signal, sampRate);

Signal = Signal__set_raw(Signal, Raw_convert_1D(rawRES));

%And we filter the signal. Else, it's useless
Signal = RES_filter_basic(Signal);


end

