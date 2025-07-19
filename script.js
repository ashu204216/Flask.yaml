// Simple JavaScript to add interactivity
document.addEventListener('DOMContentLoaded', function() {
    console.log('Static website loaded successfully!');
    
    // Add a simple animation to the header
    const header = document.querySelector('header h1');
    if (header) {
        header.style.opacity = '0';
        header.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            header.style.transition = 'opacity 1s ease, transform 1s ease';
            header.style.opacity = '1';
            header.style.transform = 'translateY(0)';
        }, 100);
    }
    
    // Add click event to sections
    const sections = document.querySelectorAll('section');
    sections.forEach(section => {
        section.addEventListener('click', function() {
            this.style.transform = 'scale(1.02)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 200);
        });
        
        // Add transition
        section.style.transition = 'transform 0.2s ease';
    });
    
    // Display current time
    function updateTime() {
        const now = new Date();
        const timeString = now.toLocaleString();
        console.log(`Page loaded at: ${timeString}`);
    }
    
    updateTime();
});
