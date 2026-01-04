export interface IHomeContentObj {
    title?: string
    items: IHomeContentObjItem[]
}

export interface IHomeContentObjItem {
    iconPath?: string
    iconAlt?: string
    iconText?: string
    itemText: string
    linkText: string
    link?: string
    linkTextSuffix?: string
}

export const aboutData: IHomeContentObj[] = [
    {
        title: "Socials 🐒",
        items: [
            {
                itemText: "Linked-In",
                iconPath: "/icons/linkedin.svg",
                iconAlt: "Linked-In",
                linkText: "cch-karl",
                link: "https://www.linkedin.com/in/cch-karl/"
            },
            {
                itemText: "E-mail",
                iconPath: "/icons/mail.svg",
                iconAlt: "Email",
                linkText: "karl@ltek.me",
                link: "mailto:karl@ltek.me?subject=Hello&amp;body=Hi%20Karl%2C%0A%0A"
            },
            {
                itemText: "Github",
                iconPath: "/icons/github.svg",
                iconAlt: "github",
                linkText: "ltekme",
                link: "https://github.com/ltekme",
                linkTextSuffix: "(thingies)"
            }
        ]
    }
];

export default aboutData;