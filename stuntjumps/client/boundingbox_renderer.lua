---@class BoundingBoxRendererClass: Class
BoundingBoxRendererClass = class()

function BoundingBoxRendererClass:dxDrawTriangleFan(c1, c2, c3, c4, c)
	local primitive = {
		{
			c1[1],
			c1[2],
			c1[3],
			c, -- Vertex 1
		},
		{
			c2[1],
			c2[2],
			c2[3],
			c, -- Vertex 2
		},
		{
			c3[1],
			c3[2],
			c3[3],
			c, -- Vertex 3
		},
		{
			c4[1],
			c4[2],
			c4[3],
			c, -- Vertex 4
		},
	}

	dxDrawPrimitive3D("trianglefan", false, unpack(primitive))
end

-- Draw the bounding box (outline and fill)
function BoundingBoxRendererClass:drawBoundingBox(corner1, corner2, outlineColor, fillColor)
	local x1, y1, z1 = corner1.x, corner1.y, corner1.z
	local x2, y2, z2 = corner2.x, corner2.y, corner2.z

	-- Calculate corners of the bounding box
	local corners = {
		{
			x1,
			y1,
			z1,
		},
		{
			x2,
			y1,
			z1,
		},
		{
			x2,
			y2,
			z1,
		},
		{
			x1,
			y2,
			z1,
		}, -- Lower corners
		{
			x1,
			y1,
			z2,
		},
		{
			x2,
			y1,
			z2,
		},
		{
			x2,
			y2,
			z2,
		},
		{
			x1,
			y2,
			z2,
		}, -- Upper corners
	}

	local outlineThickness = 2
	-- Draw the thick lines for the bounding box outline
	for i = 1, 4 do
		dxDrawLine3D(
			corners[i][1],
			corners[i][2],
			corners[i][3],
			corners[i % 4 + 1][1],
			corners[i % 4 + 1][2],
			corners[i % 4 + 1][3],
			outlineColor,
			outlineThickness
		) -- Bottom
		dxDrawLine3D(
			corners[i + 4][1],
			corners[i + 4][2],
			corners[i + 4][3],
			corners[i % 4 + 5][1],
			corners[i % 4 + 5][2],
			corners[i % 4 + 5][3],
			outlineColor,
			outlineThickness
		) -- Top
		dxDrawLine3D(
			corners[i][1],
			corners[i][2],
			corners[i][3],
			corners[i + 4][1],
			corners[i + 4][2],
			corners[i + 4][3],
			outlineColor,
			outlineThickness
		) -- Verticals
	end

	-- Draw the faces of the bounding box
	self:dxDrawTriangleFan(corners[1], corners[2], corners[3], corners[4], fillColor) -- Bottom face
	self:dxDrawTriangleFan(corners[5], corners[6], corners[7], corners[8], fillColor) -- Top face
	self:dxDrawTriangleFan(corners[1], corners[2], corners[6], corners[5], fillColor) -- South face
	self:dxDrawTriangleFan(corners[2], corners[3], corners[7], corners[6], fillColor) -- East face
	self:dxDrawTriangleFan(corners[3], corners[4], corners[8], corners[7], fillColor) -- North face
	self:dxDrawTriangleFan(corners[4], corners[1], corners[5], corners[8], fillColor) -- West face
end

BoundingBoxRenderer = BoundingBoxRendererClass:new() --[[@as BoundingBoxRendererClass]]
