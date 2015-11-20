--[[

Functions:

yBound
pyth
xyToScreen
--]]
function yBound(x,size)
	local lb = -size
	local ub = size
	if lb < x-size then lb = x-size end
	if ub > x+size then ub = x+size end
	return lb,ub
end

function pyth(dx,dy)
	return math.sqrt(dx^2+dy^2)
end

function xyToScreen(x,y)
	return x*x1+y*y1+cx, x*x2+y*y2+cy
end

