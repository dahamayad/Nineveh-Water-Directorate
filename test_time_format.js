
function formatTime12Hour(timeStr) {
    if (!timeStr) return '';
    const [hours, minutes] = timeStr.split(':').map(Number);
    const period = hours >= 12 ? 'م' : 'ص';
    const hours12 = hours % 12 || 12;
    return `${hours12}:${minutes.toString().padStart(2, '0')} ${period}`;
}

console.log("Testing formatTime12Hour:");
console.log("'12:30' ->", formatTime12Hour('12:30'));
console.log("'00:00' ->", formatTime12Hour('00:00'));
console.log("'13:05' ->", formatTime12Hour('13:05'));
console.log("'NaN:12' ->", formatTime12Hour('NaN:12'));
console.log("'undefined:12' ->", formatTime12Hour('undefined:12'));
console.log("'null:12' ->", formatTime12Hour('null:12'));
console.log("':12' ->", formatTime12Hour(':12'));
console.log("'12:' ->", formatTime12Hour('12:'));
console.log("'NaN:NaN' ->", formatTime12Hour('NaN:NaN'));
console.log("'Invalid Date' ->", formatTime12Hour('Invalid Date'));
