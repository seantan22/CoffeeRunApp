module.exports = {
    emailStrength: function (email){
        var reg =/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/
        return !reg.test(email);
    },    
    passwordStrength: function (password){
    
        // Ensure string has at least 1 uppercase
        // Ensure string has at least 1 number or special case letter
        // Ensure string has at least 1 lowercase
        // Ensure string has at least length 8
    
        var reg =/(?=^.{8,}$)((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/
        return !reg.test(password);
    },   
    phoneStrength: function (phone){
        var reg =/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/
        return !reg.test(phone);
    }
};