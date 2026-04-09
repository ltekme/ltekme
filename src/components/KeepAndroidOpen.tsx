"use client";

import { useEffect, useState } from "react";


const formatCountdown = (distance: number) => {
    if (distance <= 0) {
        return "0d 0h 0m 0s";
    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24));
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((distance % (1000 * 60)) / 1000);

    return `${days}d ${hours}h ${minutes}m ${seconds}s`;
}

const KeepAndroidOpen = () => {
    const tgt = new Date("2026-09-01T00:00:00Z").getTime();
    const [remainingText, setRemainingText] = useState(formatCountdown(tgt - Date.now()));

    useEffect(() => {
        const updateCountdown = () => {
            setRemainingText(formatCountdown(tgt - Date.now()));
        };

        updateCountdown();
        return () => window.clearInterval(window.setInterval(updateCountdown, 1000));
    }, [tgt]);

    return (
        <div>
            <a className="text-red-500 underline decoration-red-500 italic"
                href="https://keepandroidopen.org" target="_blank" rel="noopener noreferrer"
            >
                Android will become a locked-down platform in
                <br />
                <span suppressHydrationWarning>{remainingText}</span>
            </a>
        </div>
    );
}

export default KeepAndroidOpen;