import React from "react"
import { FireCMSCloudApp } from "@firecms/cloud";
import appConfig from "./index";

function App() {
    return <FireCMSCloudApp
        projectId={"thecarveout-ce0f3"}
        appConfig={appConfig}
    />;
}

export default App
