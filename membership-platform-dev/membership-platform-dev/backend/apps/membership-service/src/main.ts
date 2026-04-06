import { NestFactory } from '@nestjs/core';
import { Logger, ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ServiceConfig } from '../config';

const { name } = ServiceConfig;

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const port = process.env.PORT ?? 3000;

  app.setGlobalPrefix('api');

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: false,
  }));

  const config = new DocumentBuilder().setTitle(name).build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup(`/${process.env.SWAGGER_DOCS_PATH!}`, app, document);

  await app.listen(port);
  Logger.log(`'${name}' running on port ${port}`, 'Bootstrap');
}
bootstrap();
