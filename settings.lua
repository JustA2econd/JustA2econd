ControlClass = Object:extend()

function ControlClass:new(id, key, image, rotate)
    self.id = id
    self.key = key
    self.image = image
    self.image_rotate = rotate
end

Left = ControlClass(1, "left", Arrow, 1.5 * math.pi)
Right = ControlClass(2, "right", Arrow, 0.5 * math.pi)
Jump = ControlClass(3, "up", Arrow, 0)
Swap = ControlClass(4, "space", Switch, 0)

controls = {Left, Right, Jump, Swap}