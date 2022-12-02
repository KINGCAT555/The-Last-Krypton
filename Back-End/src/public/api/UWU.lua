local MyClass = {
    Data = {};
};

function MyClass:Set(FruitName, Number, Data)
    if type(self.Data[FruitName]) ~= "table" then
        self.Data[FruitName] = {};
    end
    self.Data[FruitName][Number] = Data;
end

MyClass:Set("Magma", "Power1", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Gas", "Power4", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Sand", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Dark", "Power4", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Chilly", "Power2", {"VTC", "FN", "SC", "M_H", "CM", "C"});
MyClass:Set("Chilly", "Power5", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Rumble", "Power2", {"VTC", "FN", "SC", "M_H_P", "M_T", "C", "ARM_P"});
MyClass:Set("Rumble", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Snow", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C", "C"});
MyClass:Set("Light", "Power2", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Light", "Power3", {"VTC", "FN", "SC", "HRP_P", "M_H_P", "C"});
MyClass:Set("String", "Power5", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("String", "Power6", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Flare", "Power2", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Flare", "Power5", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Flare", "Power6", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Love", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Love", "Power4", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Love", "Power5", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Love", "Power6", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Phoenix", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Quake", "Power1", {"VTC", "FN", "SC", "M_T", "M_H", "C", "ARM_P"});
MyClass:Set("Quake", "Power2", {"VTC", "FN", "SC", "M_H", "nil", "C", "ARM_P", "ARM_P"}); -- แขน 2 ข้าง
MyClass:Set("Quake", "Power3", {"VTC", "FN", "SC", "M_T", "M_H", "C", "ARM_P"});
MyClass:Set("Quake", "Power4", {"VTC", "FN", "SC", "M_T", "M_H", "C", "ARM_P"});
MyClass:Set("Candy", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Bomb", "Power1", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Bomb", "Power2", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Bomb", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Bomb", "Power4", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Bomb", "Power5", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Bomb", "Power6", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Venom", "Power3", {"VTC", "FN", "SC", "M_H", "M_T", "C", "DS_SL", "DS_DL"});
MyClass:Set("Rumble1", "Power2", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Light", "Power2", {"VTC", "FN", "SC", "M_H", "M_T", "C"});
MyClass:Set("Gravity", "Power2", {"VTC", "FN", "SC", "M_H", "GT", "C"});
MyClass:Set("Gravity", "Power4", {"VTC", "FN", "SC", "nil", "nil", "C"});
MyClass:Set("Gravity", "Power6", {"VTC", "FN", "SC", "C_GDP", "GT", "C"});
MyClass:Set("Plasma", "Power4", {"VTC", "FN", "SC", "M_H_P", "nil", "C"});




function MyClass:Get(FruitName)
    if self.Data[FruitName] then
        return self.Data[FruitName]
    end
    return error("Fruit not found!")
end


return MyClass