export const EnvConfig = () => {
    return {
        port: +process.env.PORT!,
        swaggerDocsPath: process.env.SWAGGER_DOCS_PATH!,
    }
}